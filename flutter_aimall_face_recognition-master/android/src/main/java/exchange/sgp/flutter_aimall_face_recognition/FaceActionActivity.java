package exchange.sgp.flutter_aimall_face_recognition;


import android.Manifest;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.blankj.utilcode.util.CleanUtils;
import com.blankj.utilcode.util.FileUtils;
import com.library.aimo.util.BitmapUtils;

import java.io.File;
import java.util.Locale;

/// 动作交互式活体检测
public class FaceActionActivity extends AppCompatActivity {
    private static final String TAG = "FaceActionActivity";

    TextView verifyTvResult;
    LinearLayout verifyLlFace;

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

        bindImoView();

        for (String permission : PERMISSION) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, PERMISSION, 1);
            }
        }

        setContentView(R.layout.activity_action);

        verifyTvResult = findViewById(R.id.verify_tv_result);
        verifyLlFace = findViewById(R.id.verify_ll_face);

        findViewById(R.id.iv_left).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                setResult(RESULT_CANCELED, intent);
                finish();
            }
        });

        TextView title = findViewById(R.id.tv_title_center);
        title.setText(getResources().getString(R.string.face_recognition));
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
        if (recognizePanel != null) {
            recognizePanel.onDestroy();
        }
        IMoBridge.release();
    }


    private IMoBridge.RecognizePanel recognizePanel;
    private boolean currentStatus = true;

    private void bindImoView() {
        Intent intent = this.getIntent();
        String key = intent.getStringExtra("imoKey");
        String languageType = intent.getStringExtra("languageType");
        setLanguage(languageType);
        IMoBridge.init(getApplication(), key, new IMoBridge.IImoInitListener() {
            @Override
            public void onSuccess() {
                recognizePanel = new IMoBridge.RecognizePanel(FaceActionActivity.this) {

                    @Override
                    protected int getCoverColor() {
                        return 0xffffffff;
                    }

                    @Override
                    protected void onFaceRectStatus(boolean isRight) {
                        if (!isRight) {
                            if (currentStatus) {
                                currentStatus = false;
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        verifyTvResult.setText(getResources().getString(R.string.please_move_face));
                                    }
                                });
                            }
                        }
                    }

                    @Override
                    protected void onFaceNotRecognized() {
                        if (currentStatus) {
                            currentStatus = false;
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    verifyTvResult.setText(getResources().getString(R.string.please_move_face));
                                    Toast.makeText(FaceActionActivity.this, getResources().getString(R.string.no_face_detected), Toast.LENGTH_SHORT).show();
                                }
                            });
                        }
                    }

                    @Override
                    public void setActionDescriptions(String... strings) {
                        super.setActionDescriptions(getResources().getString(R.string.turn_left), getResources().getString(R.string.turn_right), getResources().getString(R.string.nod_up_and_down), getResources().getString(R.string.open_your_mouth));
                    }

                    @Override
                    protected void onActionChanged(int currentAction, int nextAction) {
                    }

                    @Override
                    protected boolean isFaceRecognized() {
                        // 人脸录入
                        return false;
                    }

                    @Override
                    protected String getLocalCacheId() {
                        return null;
                    }

                    ProgressDialog progressDialog;

                    @Override
                    protected void onFaceRecorded(String id, Bitmap bitmap) {
                        final String cacheBitmap = IMoBridge.saveBitmapCache(getApplication().getCacheDir(), bitmap, "");
                        FileUtils.deleteAllInDir(new File(getApplication().getCacheDir(), "cacheBitmap"));
//                        final float[] features = IMoBridge.getBitmapFeature(bitmap);
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                recognizePanel.onPause();
                                Intent intent = new Intent();
                                intent.putExtra("image", cacheBitmap);
                                setResult(RESULT_OK, intent);
                                finish();
//                                verifyTvStatus.setText("success");
//                                recognizePanel.onPause();
//                                progressDialog = new ProgressDialog(FaceActionActivity.this);
//                                progressDialog.setTitle("tip");
//                                progressDialog.setMessage("Loading...");
//                                progressDialog.setCancelable(true);
//                                progressDialog.show();
//                                IMoBridge.buildVideo(recognizePanel, new IMoBridge.IImoVideoBuildListener() {
//                                    @Override
//                                    public void onSuccess(String path) {
//                                        runOnUiThread(new Runnable() {
//                                            @Override
//                                            public void run() {
//                                                if (progressDialog != null) {
//                                                    progressDialog.dismiss();
//                                                }
//                                                StringBuffer stringBuffer = new StringBuffer();
//                                                stringBuffer.append("图片地址：" + cacheBitmap);
//                                                stringBuffer.append("\n");
////                                                stringBuffer.append("视频地址：" + path);
//                                                stringBuffer.append("\n");
//                                                stringBuffer.append("视频时长：" + recognizePanel.getTime() + " 秒");
//                                                stringBuffer.append("\n");
//                                                stringBuffer.append("图片特征值：" + Arrays.toString(features));
//
//                                                verifyTvResult.setText(stringBuffer.toString());
//                                            }
//                                        });
//                                    }
//                                });
                            }
                        });
                    }

                    @Override
                    protected void onFaceRecognized(float score, Bitmap bitmap, String id) {
                    }

                    @Override
                    protected void showRecognitionTimeoutDialog() {
                        AlertDialog alertDialog1 = new AlertDialog.Builder(FaceActionActivity.this)
                                .setTitle(getResources().getString(R.string.recognition_failure))//标题
                                .setCancelable(false)
                                .setMessage(getResources().getString(R.string.cannot_recognize_face))//内容
                                .setPositiveButton(getResources().getString(R.string.re_identify), new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialogInterface, int i) {
                                        recognizePanel.startRandomAction(false);
                                    }
                                })
                                .setNegativeButton(getResources().getString(R.string.cancel), new DialogInterface.OnClickListener() {
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
                };

                int widthHeight = (int) (240 * getResources().getDisplayMetrics().density);
                verifyLlFace.addView(recognizePanel.onCreate(), new LinearLayout.LayoutParams(widthHeight, widthHeight));
                recognizePanel.startRecordByAction(false);
            }

            @Override
            public void onFail(int code) {
                Toast.makeText(FaceActionActivity.this, code == -1 ? getResources().getString(R.string.device_cannot_support) : getResources().getString(R.string.failed_to_initialize_face), Toast.LENGTH_SHORT).show();
                Intent intent = new Intent();
                setResult(RESULT_CANCELED, intent);
                finish();
            }
        });
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