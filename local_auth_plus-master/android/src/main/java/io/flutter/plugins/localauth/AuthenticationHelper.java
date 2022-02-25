// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth;

import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.graphics.Point;
import android.hardware.fingerprint.FingerprintManager;
import android.os.Build;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicReference;

import io.flutter.plugin.common.MethodCall;

/**
 * Authenticates the user with biometrics and sends corresponding response back to Flutter.
 *
 * <p>One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
@SuppressWarnings("deprecation")
class AuthenticationHelper extends BiometricPrompt.AuthenticationCallback
        implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
    private static final String TAG = "AuthenticationHelper";

    /**
     * The callback that handles the result of this authentication process.
     */
    public interface AuthCompletionHandler {
        /**
         * Called when authentication was successful.
         */
        void onSuccess();

        /**
         * Called when authentication failed due to user. For instance, when user cancels the auth or
         * quits the app.
         */
        void onFailure();

        /**
         * Called when authentication fails due to non-user related problems such as system errors,
         * phone not having a FP reader etc.
         *
         * @param code  The error code to be returned to Flutter app.
         * @param error The description of the error.
         */
        void onError(String code, String error);
    }

    // This is null when not using v2 embedding;
    private final Lifecycle lifecycle;
    private final FragmentActivity activity;
    private final AuthCompletionHandler completionHandler;
    private final MethodCall call;
    private final BiometricPrompt.PromptInfo promptInfo;
    private final boolean isAuthSticky;
    private final UiThreadExecutor uiThreadExecutor;
    private boolean activityPaused = false;
    private BiometricPrompt biometricPrompt;

    private final boolean isUseCustomUi;
    @Nullable
    private CancellationSignal cancellationSignal;

    AuthenticationHelper(
            Lifecycle lifecycle,
            FragmentActivity activity,
            MethodCall call,
            AuthCompletionHandler completionHandler,
            boolean allowCredentials) {
        this.lifecycle = lifecycle;
        this.activity = activity;
        this.completionHandler = completionHandler;
        this.call = call;
        this.isAuthSticky = call.argument("stickyAuth");
        this.isUseCustomUi = call.argument("androidCustomUi");
        this.uiThreadExecutor = new UiThreadExecutor();

        BiometricPrompt.PromptInfo.Builder promptBuilder =
                new BiometricPrompt.PromptInfo.Builder()
                        .setDescription((String) call.argument("localizedReason"))
                        .setTitle((String) call.argument("signInTitle"))
                        .setSubtitle((String) call.argument("biometricHint"))
                        .setConfirmationRequired((Boolean) call.argument("sensitiveTransaction"))
                        .setConfirmationRequired((Boolean) call.argument("sensitiveTransaction"));

        if (allowCredentials) {
            promptBuilder.setDeviceCredentialAllowed(true);
        } else {
            promptBuilder.setNegativeButtonText((String) call.argument("cancelButton"));
        }
        this.promptInfo = promptBuilder.build();
    }

    /**
     * Start the biometric listener.
     */
    void authenticate() {
        if (lifecycle != null) {
            lifecycle.addObserver(this);
        } else {
            activity.getApplication().registerActivityLifecycleCallbacks(this);
        }
        if (isUseCustomUi && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            authenticateUseCustomUI();
        } else {
            biometricPrompt = new BiometricPrompt(activity, uiThreadExecutor, this);
            biometricPrompt.authenticate(promptInfo);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private void authenticateUseCustomUI() {
        final AtomicReference<AuthenticateDialog> dialog = new AtomicReference<>(null);
        FingerprintManager fm = (FingerprintManager) activity.getSystemService(Context.FINGERPRINT_SERVICE);
        cancellationSignal = new CancellationSignal();
        fm.authenticate(null, cancellationSignal, 0, new FingerprintManager.AuthenticationCallback() {
            @Override
            public void onAuthenticationError(int errorCode, CharSequence errString) {
                Log.d(TAG, "onAuthenticationError: " + errorCode + ", " + errString);
                switch (errorCode) {
                    case FingerprintManager.FINGERPRINT_ERROR_NO_SPACE:
                    case FingerprintManager.FINGERPRINT_ERROR_NO_FINGERPRINTS:
                        if (promptInfo.isDeviceCredentialAllowed()) return;
                        if (call.argument("useErrorDialogs")) {
                            showGoToSettingsDialog(
                                    (String) call.argument("biometricRequired"),
                                    (String) call.argument("goToSettingDescription"));
                            return;
                        }
                        completionHandler.onError("NotEnrolled", "No Biometrics enrolled on this device.");
                        break;
                    case FingerprintManager.FINGERPRINT_ERROR_HW_NOT_PRESENT:
                    case FingerprintManager.FINGERPRINT_ERROR_HW_UNAVAILABLE:
                        completionHandler.onError("NotAvailable", "Security credentials not available.");
                        break;
                    case FingerprintManager.FINGERPRINT_ERROR_LOCKOUT:
                        completionHandler.onError(
                                "LockedOut",
                                "The operation was canceled because the API is locked out due to too many attempts. This occurs after 5 failed attempts, and lasts for 30 seconds.");
                        break;
                    case FingerprintManager.FINGERPRINT_ERROR_LOCKOUT_PERMANENT:
                        completionHandler.onError(
                                "PermanentlyLockedOut",
                                "The operation was canceled because ERROR_LOCKOUT occurred too many times. Biometric authentication is disabled until the user unlocks with strong authentication (PIN/Pattern/Password)");
                        break;
                    case FingerprintManager.FINGERPRINT_ERROR_CANCELED:
                        // If we are doing sticky auth and the activity has been paused,
                        // ignore this error. We will start listening again when resumed.
                        if (activityPaused && isAuthSticky) {
                            return;
                        } else {
                            completionHandler.onFailure();
                        }
                        break;
                    default:
                        completionHandler.onFailure();
                        break;
                }
                if (dialog.get() != null) {
                    dialog.get().dismiss();
                    dialog.set(null);
                }
            }

            @Override
            public void onAuthenticationSucceeded(FingerprintManager.AuthenticationResult result) {
                Log.d(TAG, "onAuthenticationSucceeded: " + result);
                completionHandler.onSuccess();
                stop();
                if (dialog.get() != null) {
                    dialog.get().dismiss();
                    dialog.set(null);
                }
            }

            @Override
            public void onAuthenticationFailed() {
                if (dialog.get() != null) {
                    dialog.get().didAuthenticationFailed();
                }
            }
        }, uiThreadExecutor.handler);
        dialog.set(createAndShowAuthenticateDialog());
    }

    private AuthenticateDialog createAndShowAuthenticateDialog() {
        final AuthenticateDialog dialog = new AuthenticateDialog(activity);
        dialog.show();
        return dialog;
    }

    private final class AuthenticateDialog extends Dialog {
        private final View contentView;
        private final TextView tvTitle;
        private final TextView tvSubTitle;
        private final TextView tvDescription;
        private final ImageView ivIcon;
        private final TextView tvCancel;

        public AuthenticateDialog(@NonNull Context context) {
            super(context, R.style.LocalAuthPromptDialogTheme);
            this.contentView = LayoutInflater.from(activity).inflate(R.layout.local_auth_prompt_dialog, null);
            this.tvTitle = contentView.findViewById(R.id.tv_title);
            this.tvSubTitle = contentView.findViewById(R.id.tv_subtitle);
            this.tvDescription = contentView.findViewById(R.id.tv_description);
            this.ivIcon = contentView.findViewById(R.id.iv_icon);
            this.tvCancel = contentView.findViewById(R.id.tv_cancel);
            tvTitle.setText(promptInfo.getTitle());
            tvTitle.setVisibility(TextUtils.isEmpty(promptInfo.getTitle()) ? View.GONE : View.VISIBLE);

            tvSubTitle.setText(promptInfo.getSubtitle());
            tvSubTitle.setVisibility(TextUtils.isEmpty(promptInfo.getSubtitle()) ? View.GONE : View.VISIBLE);

            tvDescription.setText(promptInfo.getDescription());
            tvDescription.setVisibility(TextUtils.isEmpty(promptInfo.getDescription()) ? View.GONE : View.VISIBLE);

            tvCancel.setText(promptInfo.getNegativeButtonText());
            tvCancel.setVisibility(TextUtils.isEmpty(promptInfo.getNegativeButtonText()) ? View.GONE : View.VISIBLE);

            tvCancel.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    AuthenticateDialog.this.cancel();
                }
            });
            this.setContentView(contentView);
            this.setCanceledOnTouchOutside(false);
            this.setOnCancelListener(new DialogInterface.OnCancelListener() {
                @Override
                public void onCancel(DialogInterface dialogInterface) {
                    stopAuthentication();
                }
            });

        }

        public void didAuthenticationFailed() {
            ivIcon.setImageResource(R.drawable.fingerprint_warning_icon);
            ObjectAnimator animator = ObjectAnimator.ofFloat(ivIcon, "translationX", 0, 100, -100, 0);
            animator.setDuration(200);
            animator.start();
        }

        @Override
        public void show() {
            super.show();
            final Window window = this.getWindow();
            if (window != null) {
                window.setWindowAnimations(R.style.LocalAuthPromptDialogAnimation);
                Point size = new Point();
                WindowManager wm = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
                wm.getDefaultDisplay().getSize(size);
                window.setLayout((int) (size.x * 0.888888), ViewGroup.LayoutParams.WRAP_CONTENT);
                window.setDimAmount(0.5f);
            }
        }
    }


    /**
     * Cancels the biometric authentication.
     */
    void stopAuthentication() {
        if (isUseCustomUi) {
            if (cancellationSignal != null) {
                cancellationSignal.cancel();
                cancellationSignal = null;
            }
        } else {
            if (biometricPrompt != null) {
                biometricPrompt.cancelAuthentication();
                biometricPrompt = null;
            }
        }
    }

    /**
     * Stops the biometric listener.
     */
    private void stop() {
        if (lifecycle != null) {
            lifecycle.removeObserver(this);
            return;
        }
        activity.getApplication().unregisterActivityLifecycleCallbacks(this);
    }


    // region BiometricPrompt.AuthenticationCallback
    @SuppressLint("SwitchIntDef")
    @Override
    public void onAuthenticationError(int errorCode, CharSequence errString) {
        switch (errorCode) {
            case BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL:
                if (call.argument("useErrorDialogs")) {
                    showGoToSettingsDialog(
                            (String) call.argument("deviceCredentialsRequired"),
                            (String) call.argument("deviceCredentialsSetupDescription"));
                    return;
                }
                completionHandler.onError("NotAvailable", "Security credentials not available.");
                break;
            case BiometricPrompt.ERROR_NO_SPACE:
            case BiometricPrompt.ERROR_NO_BIOMETRICS:
                if (promptInfo.isDeviceCredentialAllowed()) return;
                if (call.argument("useErrorDialogs")) {
                    showGoToSettingsDialog(
                            (String) call.argument("biometricRequired"),
                            (String) call.argument("goToSettingDescription"));
                    return;
                }
                completionHandler.onError("NotEnrolled", "No Biometrics enrolled on this device.");
                break;
            case BiometricPrompt.ERROR_HW_UNAVAILABLE:
            case BiometricPrompt.ERROR_HW_NOT_PRESENT:
                completionHandler.onError("NotAvailable", "Security credentials not available.");
                break;
            case BiometricPrompt.ERROR_LOCKOUT:
                completionHandler.onError(
                        "LockedOut",
                        "The operation was canceled because the API is locked out due to too many attempts. This occurs after 5 failed attempts, and lasts for 30 seconds.");
                break;
            case BiometricPrompt.ERROR_LOCKOUT_PERMANENT:
                completionHandler.onError(
                        "PermanentlyLockedOut",
                        "The operation was canceled because ERROR_LOCKOUT occurred too many times. Biometric authentication is disabled until the user unlocks with strong authentication (PIN/Pattern/Password)");
                break;
            case BiometricPrompt.ERROR_CANCELED:
                // If we are doing sticky auth and the activity has been paused,
                // ignore this error. We will start listening again when resumed.
                if (activityPaused && isAuthSticky) {
                    return;
                } else {
                    completionHandler.onFailure();
                }
                break;
            default:
                completionHandler.onFailure();
        }
        stop();
    }

    @Override
    public void onAuthenticationSucceeded(BiometricPrompt.AuthenticationResult result) {
        completionHandler.onSuccess();
        stop();
    }

    @Override
    public void onAuthenticationFailed() {
    }
    // endregion

    /**
     * If the activity is paused, we keep track because biometric dialog simply returns "User
     * cancelled" when the activity is paused.
     */
    @Override
    public void onActivityPaused(Activity ignored) {
        if (isAuthSticky) {
            activityPaused = true;
        }
    }

    @Override
    public void onActivityResumed(Activity ignored) {
        if (isAuthSticky) {
            activityPaused = false;
            if (isUseCustomUi && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (cancellationSignal != null && cancellationSignal.isCanceled()) {
                    uiThreadExecutor.handler.post(new Runnable() {
                        @Override
                        public void run() {
                            authenticateUseCustomUI();
                        }
                    });
                }
            } else {
                final BiometricPrompt prompt = new BiometricPrompt(activity, uiThreadExecutor, this);
                // When activity is resuming, we cannot show the prompt right away. We need to post it to the
                // UI queue.
                uiThreadExecutor.handler.post(
                        new Runnable() {
                            @Override
                            public void run() {
                                prompt.authenticate(promptInfo);
                            }
                        });
            }
        }
    }

    @Override
    public void onPause(@NonNull LifecycleOwner owner) {
        onActivityPaused(null);
    }

    @Override
    public void onResume(@NonNull LifecycleOwner owner) {
        onActivityResumed(null);
    }

    // Suppress inflateParams lint because dialogs do not need to attach to a parent view.
    @SuppressLint("InflateParams")
    private void showGoToSettingsDialog(String title, String descriptionText) {
        View view = LayoutInflater.from(activity).inflate(R.layout.go_to_setting, null, false);
        TextView message = (TextView) view.findViewById(R.id.fingerprint_required);
        TextView description = (TextView) view.findViewById(R.id.go_to_setting_description);
        message.setText(title);
        description.setText(descriptionText);
        Context context = new ContextThemeWrapper(activity, R.style.AlertDialogCustom);
        OnClickListener goToSettingHandler =
                new OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        completionHandler.onFailure();
                        stop();
                        activity.startActivity(new Intent(Settings.ACTION_SECURITY_SETTINGS));
                    }
                };
        OnClickListener cancelHandler =
                new OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        completionHandler.onFailure();
                        stop();
                    }
                };
        new AlertDialog.Builder(context)
                .setView(view)
                .setPositiveButton((String) call.argument("goToSetting"), goToSettingHandler)
                .setNegativeButton((String) call.argument("cancelButton"), cancelHandler)
                .setCancelable(false)
                .show();
    }

    // Unused methods for activity lifecycle.

    @Override
    public void onActivityCreated(Activity activity, Bundle bundle) {
    }

    @Override
    public void onActivityStarted(Activity activity) {
    }

    @Override
    public void onActivityStopped(Activity activity) {
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner owner) {
    }

    @Override
    public void onStop(@NonNull LifecycleOwner owner) {
    }

    @Override
    public void onStart(@NonNull LifecycleOwner owner) {
    }

    @Override
    public void onCreate(@NonNull LifecycleOwner owner) {
    }

    private static class UiThreadExecutor implements Executor {
        final Handler handler = new Handler(Looper.getMainLooper());

        @Override
        public void execute(Runnable command) {
            handler.post(command);
        }
    }
}
