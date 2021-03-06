package exchange.sgp.flutter_aimall_face_recognition;


import android.content.DialogInterface;
import android.content.Intent;
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

import com.blankj.utilcode.util.FileUtils;
import com.library.aimo.EasyLibUtils;
import com.library.aimo.util.BitmapUtils;

import java.io.File;
import java.util.List;
import java.util.Locale;

import exchange.sgp.flutter_aimall_face_recognition.bean.UserFaceBean;
import exchange.sgp.flutter_aimall_face_recognition.data.DatabaseHelper;
import exchange.sgp.flutter_aimall_face_recognition.db.DaoSession;
import exchange.sgp.flutter_aimall_face_recognition.db.UserFaceBeanDao;

public class FaceLoginActivity extends AppCompatActivity {
    private static final String TAG = "FaceLoginActivity";
    //    TextView verifyTvStatus;
    TextView verifyTvResult;
    LinearLayout verifyLlFace;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        bindImoView();
        setContentView(R.layout.activity_action);

//        verifyTvStatus = findViewById(R.id.verify_tv_status);
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
        title.setText(getResources().getString(R.string.face_login));
    }


    private IMoBridge.RecognizePanel recognizePanel;
    private boolean currentStatus = true;


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

    private void bindImoView() {
        final Intent intent = this.getIntent();
        String key = intent.getStringExtra("imoKey");
        String languageType = intent.getStringExtra("languageType");
        setLanguage(languageType);
        IMoBridge.init(getApplication(), key, new IMoBridge.IImoInitListener() {
            @Override
            public void onSuccess() {
                recognizePanel = new IMoBridge.RecognizePanel(FaceLoginActivity.this) {

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
                                    verifyTvResult.setText(getResources().getString(R.string.please_move_face));
                                    Toast.makeText(FaceLoginActivity.this, getResources().getString(R.string.no_face_detected), Toast.LENGTH_SHORT).show();
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
                        return intent.getStringExtra("userId");
                    }

                    @Override
                    protected void onFaceRecorded(String id, Bitmap bitmap) {
                    }

                    @Override
                    protected void onFaceRecognized(float score, Bitmap bitmap, final String id) {
//                        IMoBridge.saveLocalFace(DemoListActivity.uid, features); //??????????????????????????????????????????

                        DaoSession daoSession = DatabaseHelper.getInstance(EasyLibUtils.getApp()).getDaoSession();
                        List<UserFaceBean> userFaces = null;
                        if (id != null) {
                            userFaces = daoSession.getUserFaceBeanDao().queryBuilder()
                                    .whereOr(UserFaceBeanDao.Properties.Email.eq(id), UserFaceBeanDao.Properties.Mobile.eq(id)).limit(1).list();
                        }

                        final String cacheBitmap = IMoBridge.saveBitmapCache(getApplication().getCacheDir(), bitmap, "");
                        FileUtils.deleteAllInDir(new File(getApplication().getCacheDir(), "cacheBitmap"));
                        final List<UserFaceBean> finalUserFaces = userFaces;
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
//                                verifyTvStatus.setText("???????????????????????????");
                                recognizePanel.onPause();

                                Intent intent = new Intent();
                                intent.putExtra("image", cacheBitmap);

                                if (finalUserFaces != null && finalUserFaces.size() > 0) {
                                    UserFaceBean userFaceBean = finalUserFaces.get(0);
                                    intent.putExtra("faceToken", userFaceBean.getFaceToken());
                                }
                                setResult(RESULT_OK, intent);
                                finish();
//                                StringBuffer stringBuffer = new StringBuffer();
//                                stringBuffer.append("??????????????????");
//                                stringBuffer.append("\n");
//                                stringBuffer.append("???????????????" + cacheBitmap);
//                                stringBuffer.append("\n");
////                                stringBuffer.append("id???" + id);
//
//                                verifyTvResult.setText(stringBuffer.toString());
                            }
                        });
                    }

                    @Override
                    protected void showRecognitionTimeoutDialog() {
                        AlertDialog alertDialog1 = new AlertDialog.Builder(FaceLoginActivity.this)
                                .setTitle(getResources().getString(R.string.recognition_failure))//??????
                                .setCancelable(false)
                                .setMessage(getResources().getString(R.string.cannot_recognize_face))//??????
                                .setPositiveButton(getResources().getString(R.string.re_identify), new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialogInterface, int i) {
                                        recognizePanel.startFaceCheck();
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
                recognizePanel.startFaceCheck();
            }

            @Override
            public void onFail(int code) {
                Toast.makeText(FaceLoginActivity.this, code == -1 ? getResources().getString(R.string.device_cannot_support) : getResources().getString(R.string.failed_to_initialize_face), Toast.LENGTH_SHORT).show();
                Intent intent = new Intent();
                setResult(RESULT_CANCELED, intent);
                finish();
            }
        });
    }

    public void setLanguage(String languageKey) {
        Log.d(TAG, "????????????????????? " + languageKey);
        if (languageKey != null && !"".equals(languageKey)) {
            // ??????????????????
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
                //??????
                myLocale = Locale.FRENCH;
            }
//            else if (TextUtils.equals(languageKey, "ES")) {
//                //????????????
//                myLocale = Locale.SPAN;
//            }
            else if (TextUtils.equals(languageKey, "KR")) {
                //??????
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