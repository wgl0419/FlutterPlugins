package exchange.sgp.flutter_aimall_face_recognition;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.blankj.utilcode.util.FileUtils;

import java.io.File;
import java.util.Locale;

public class FaceStaticActivity extends AppCompatActivity {
    private static final String TAG = "FaceStaticActivity";

    TextView verifyTvStatus;
    TextView verifyTvStart;
    FrameLayout verifyLlFace;

    Integer status; // -1 开始, 0: 进行中, 1: 完成

    ProgressDialog progressDialog;

    ImageView imageView1, imageView2, imageView3;

    private static final String[] PERMISSION = new String[]{
            //获取照相机权限
            Manifest.permission.CAMERA,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE,
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        final Intent intent = this.getIntent();
        String key = intent.getStringExtra("imoKey");
        String languageType = intent.getStringExtra("languageType");
        setLanguage(languageType);

        for (String permission : PERMISSION) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, PERMISSION, 1);
            }
        }

        setContentView(R.layout.activity_static);

        verifyTvStatus = findViewById(R.id.camera_tv_desc);
        verifyLlFace = findViewById(R.id.verify_ll_face);

        imageView1 = findViewById(R.id.auth_iv_example1);
        imageView2 = findViewById(R.id.auth_iv_example2);
        imageView3 = findViewById(R.id.auth_iv_example3);

        verifyTvStart = findViewById(R.id.camera_iv_start);
        verifyTvStart.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
        this.setStatus(-1);
        verifyTvStart.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (status != 0) {
                    start();
                }
            }
        });
        findViewById(R.id.iv_close).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                setResult(RESULT_CANCELED, intent);
                finish();
            }
        });
        bindImoView(key);
    }

    public void setStatus(Integer status) {
        this.status = status;
        verifyTvStart = findViewById(R.id.camera_iv_start);
        if (status == 0) {
            verifyTvStart.setTextColor(Color.parseColor("#EC6A6A"));
            verifyTvStart.setTextSize(20);
        } else {
            verifyTvStart.setTextColor(Color.parseColor("#137ADB"));
            verifyTvStart.setTextSize(13);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (recognizePanel != null) {
            recognizePanel.onResume();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (recognizePanel != null) {
            recognizePanel.onPause();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (timer != null) {
            timer.cancel();
        }
        if (recognizePanel != null) {
            recognizePanel.onDestroy();
        }
        IMoBridge.release();
    }


    private IMoBridge.RecognizePanel recognizePanel;
    private boolean currentStatus = true;

    private void bindImoView(String key) {
        IMoBridge.init(getApplication(), key, new IMoBridge.IImoInitListener() {
            @Override
            public void onSuccess() {
                recognizePanel = new IMoBridge.RecognizePanel(FaceStaticActivity.this) {

                    @Override
                    protected int getCoverColor() {
                        return 0xffffffff;
                    }

                    @Override
                    protected void onFaceRectStatus(boolean isRight) {
                    }

                    @Override
                    protected void onFaceNotRecognized() {
                        if (currentStatus) {
                            currentStatus = false;
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    verifyTvStatus.setText(getResources().getString(R.string.please_move_face));
//                                    Toast.makeText(FaceStaticActivity.this, "未检测到人脸", Toast.LENGTH_SHORT).show();
                                }
                            });
                        }
                    }

                    @Override
                    protected void onActionChanged(int currentAction, int nextAction) {
                    }

                    @Override
                    protected boolean isFaceRecognized() {
                        return true;
                    }

                    @Override
                    protected String getLocalCacheId() {
                        return null;//notice：这里必须为null
                    }


                    @Override
                    protected void onFaceRecorded(String id, Bitmap bitmap) {
                    }

                    @Override
                    protected void onFaceRecognized(float score, final Bitmap bitmap, String id) {
                        if (score < 0.9) {
                            return;
                        }
                        currentStatus = true;
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (currentTime >= 10000 * 2 / 3) {
                                    imageView1.setImageBitmap(bitmap);
                                } else if (currentTime >= 10000 / 3) {
                                    if (imageView1.getDrawable() == null) {
                                        imageView1.setImageBitmap(bitmap);
                                    } else {
                                        imageView2.setImageBitmap(bitmap);
                                    }
                                } else {
                                    if (imageView1.getDrawable() == null) {
                                        imageView1.setImageBitmap(bitmap);
                                    } else if (imageView2.getDrawable() == null) {
                                        imageView2.setImageBitmap(bitmap);
                                    } else {
                                        imageView3.setImageBitmap(bitmap);
                                    }
                                }
                            }
                        });
                    }

                    @Override
                    protected void showRecognitionTimeoutDialog() {
                        if (imageView3.getDrawable() == null) {
                            AlertDialog alertDialog1 = new AlertDialog.Builder(FaceStaticActivity.this)
                                    .setTitle(getResources().getString(R.string.recognition_failure))//标题
                                    .setMessage(getResources().getString(R.string.cannot_recognize_face))//内容
                                    .setCancelable(false)
                                    .setPositiveButton(getResources().getString(R.string.re_identify), new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialogInterface, int i) {
                                            start();
                                        }
                                    })
                                    .setNegativeButton(getResources().getString(R.string.cancel), new DialogInterface.OnClickListener() {//添加取消
                                        @Override
                                        public void onClick(DialogInterface dialogInterface, int i) {
                                            Intent intent = new Intent();
                                            setResult(RESULT_CANCELED, intent);
                                            finish();
                                        }
                                    })

                                    .create();
                            alertDialog1.show();
                        }
                    }
                };

                verifyLlFace.addView(recognizePanel.onCreate(), 0, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                recognizePanel.disableClip();
                recognizePanel.onResume();
            }

            @Override
            public void onFail(int code) {
                Toast.makeText(FaceStaticActivity.this, code == -1 ? getResources().getString(R.string.device_cannot_support) : getResources().getString(R.string.failed_to_initialize_face), Toast.LENGTH_SHORT).show();
                Intent intent = new Intent();
                setResult(RESULT_CANCELED, intent);
                finish();
            }
        });
    }

    private void start() {
        if (status == 1) {
            progressDialog = new ProgressDialog(FaceStaticActivity.this);
            progressDialog.setMessage(getResources().getString(R.string.processing));
            progressDialog.setCancelable(false);
            progressDialog.show();

            new Thread(new Runnable() {
                @Override
                public void run() {
                    final Intent intent = new Intent();
                    Bitmap bitmap1 = getBitmapWithImageView(imageView1);
                    Bitmap bitmap2 = getBitmapWithImageView(imageView2);
                    Bitmap bitmap3 = getBitmapWithImageView(imageView3);
                    final String cacheBitmap1 = IMoBridge.saveBitmapCache(getApplication().getCacheDir(), bitmap1);
                    final String cacheBitmap2 = IMoBridge.saveBitmapCache(getApplication().getCacheDir(), bitmap2);
                    final String cacheBitmap3 = IMoBridge.saveBitmapCache(getApplication().getCacheDir(), bitmap3);

                    intent.putExtra("image1", cacheBitmap1);
                    intent.putExtra("image2", cacheBitmap2);
                    intent.putExtra("image3", cacheBitmap3);

                    IMoBridge.buildVideo(new File(getApplication().getCacheDir(), "cacheBitmap"), recognizePanel, new IMoBridge.IImoVideoBuildListener() {
                        @Override
                        public void onSuccess(String path) {
                            intent.putExtra("video", path);
                            FileUtils.deleteAllInDir(new File(getApplication().getCacheDir(), "cacheBitmap"));
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    progressDialog.dismiss();
                                    setResult(RESULT_OK, intent);
                                    finish();
                                }
                            });
                        }
                    });
                }
            }).start();
            return;
        }
        if (recognizePanel != null)
            recognizePanel.startFaceCheck();
        countDown(10 * 1000);
    }

    private Bitmap getBitmapWithImageView(ImageView imageView) {
        imageView.setDrawingCacheEnabled(true);
        Bitmap bitmap = Bitmap.createBitmap(imageView.getDrawingCache());
        imageView.setDrawingCacheEnabled(false);
        return bitmap;
    }

    CountDownTimer timer;
    long currentTime;

    private void countDown(long lsTime) {
        setStatus(0);
        verifyTvStart.setText("" + lsTime / 1000);
        timer = new CountDownTimer(lsTime, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                currentTime = millisUntilFinished;
                verifyTvStart.setText("" + millisUntilFinished / 1000);
            }

            @Override
            public void onFinish() {
                if (imageView3.getDrawable() != null) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            setStatus(1);
                            verifyTvStart.setText(getResources().getString(R.string.carry_out));
                        }
                    });
                }
                timer = null;
            }
        }.start();
    }

    public void setLanguage(String languageKey) {
        Log.d(TAG, "设置语言类型： " + languageKey);
        if (languageKey != null && !"".equals(languageKey)) {
            // 本地语言设置
            Locale myLocale = null;
            if (TextUtils.equals(languageKey, "ZH_CN")) {
//                myLocale = new Locale(languageKey, Locale.CHINESE.getCountry());
                myLocale = Locale.CHINA;
            } else if (TextUtils.equals(languageKey, "EN") || TextUtils.equals(languageKey, "en_US")) {
//                myLocale = new Locale( "en",Locale.ENGLISH.getCountry());
                myLocale = Locale.ENGLISH;
            } else if (TextUtils.equals(languageKey, "JP")) {
//                myLocale = new Locale( "ja",Locale.JAPAN.getCountry());
                myLocale = Locale.JAPAN;
            } else if (TextUtils.equals(languageKey, "FRA")) {
                //法语
                myLocale = Locale.FRENCH;
            }
//            else if (TextUtils.equals(languageKey, "ES")) {
//                //西班牙语
//                myLocale = Locale.SPAN;
//            }
            else if (TextUtils.equals(languageKey, "KR")) {
                //韩语
                myLocale = Locale.KOREA;
            } else {
//                myLocale = new Locale("zh-rTW",Locale.TRADITIONAL_CHINESE.getCountry());
                myLocale = Locale.TAIWAN;
            }
            Resources res = getResources();
            DisplayMetrics dm = res.getDisplayMetrics();
            Configuration conf = res.getConfiguration();
            conf.locale = myLocale;
            res.updateConfiguration(conf, dm);
        }
    }


}