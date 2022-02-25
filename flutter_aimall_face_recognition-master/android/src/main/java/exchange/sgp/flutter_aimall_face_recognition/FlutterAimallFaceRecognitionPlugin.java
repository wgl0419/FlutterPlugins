package exchange.sgp.flutter_aimall_face_recognition;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.annotation.NonNull;

import com.blankj.utilcode.util.FileUtils;
import com.library.aimo.api.IMoRecognitionManager;
import com.library.aimo.api.IMoSDKManager;
import com.library.aimo.config.SettingConfig;
import com.library.aimo.util.BitmapUtils;
import com.library.aimo.util.ImoLog;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import exchange.sgp.flutter_aimall_face_recognition.bean.UserFaceBean;
import exchange.sgp.flutter_aimall_face_recognition.data.DatabaseHelper;
import exchange.sgp.flutter_aimall_face_recognition.db.DaoSession;
import exchange.sgp.flutter_aimall_face_recognition.db.UserFaceBeanDao;
import exchange.sgp.flutter_aimall_face_recognition.utils.ByteConvert;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * FlutterAimallFaceRecognitionPlugin
 */
public class FlutterAimallFaceRecognitionPlugin implements FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener, ActivityAware {

    private MethodChannel channel;
    private Activity mActivity;
    private Context mContext;
    private Result mResult;
    private String imoKey;
    String languageType = "zh_TW";

    public static final int RESULT_ACTION_LIVING = 9990; // 动作活体检测
    public static final int RESULT_CERT_LIVING = 9991; // 实名采集
    public static final int RESULT_SILENT_LIVING = 9992; // 静默活体检测

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_aimall_face_recognition");
        channel.setMethodCallHandler(this);
        mContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        this.mResult = result;
        Log.d("onMethodCall", "爱莫多语言类型：" + languageType);
        switch (call.method) {
            case "initImoSDK": {
                imoKey = call.<String>argument("imoKey");
                languageType = call.<String>argument("languageType");
                final Map<String, Object> map = new HashMap<>();
                map.put("code", 200);
                mResult.success(map);
                break;
            }
            case "livingSampling": {
                Intent intent = new Intent(mActivity, FaceStaticActivity.class);
                intent.putExtra("imoKey", imoKey);
                intent.putExtra("languageType", languageType);
                mActivity.startActivityForResult(intent, RESULT_CERT_LIVING);
                break;
            }
            case "actionLiving": {
                Intent intent = new Intent(mContext, FaceActionActivity.class);
                intent.putExtra("imoKey", imoKey);
                intent.putExtra("languageType", languageType);
                mActivity.startActivityForResult(intent, RESULT_ACTION_LIVING);
                break;
            }
            case "silentLiving": {
                Intent intent = new Intent(mActivity, FaceLoginActivity.class);
                intent.putExtra("imoKey", imoKey);
                intent.putExtra("userId", call.<String>argument("userName"));
                intent.putExtra("languageType", languageType);
                mActivity.startActivityForResult(intent, RESULT_SILENT_LIVING);
                break;
            }
            case "faceSimilarityComparison": {
                String originImage = call.<String>argument("originImage");
                List<String> targetImages = call.<List<String>>argument("targetImages");
                faceSimilarityComparison(originImage, targetImages);
                break;
            }
            case "saveFaceToLocal": {
                String userId = call.<String>argument("userId");
                String email = call.<String>argument("email");
                String mobile = call.<String>argument("mobile");
                String faceToken = call.<String>argument("faceToken");
                String faceImage = call.<String>argument("faceImage");
                saveFaceToLocal(userId, email, mobile, faceToken, faceImage);
                break;
            }
            case "updateFaceToken": {
                String userId = call.<String>argument("userId");
                String faceToken = call.<String>argument("faceToken");
                updateFaceToken(userId, faceToken);
                break;
            }
            case "deleteFaceToken": {
                String faceToken = call.<String>argument("faceToken");
                deleteFaceToken(faceToken);
                break;
            }
            case "deleteAllUserFace": {
                deleteAllUserFace();
                break;
            }
            case "takeCardImage": {
                final Map<String, Object> map = new HashMap<>();
                Boolean isFront = call.<Boolean>argument("isFront");
                IMoSDKManager.KEY = imoKey;
                CardCameraActivity.headRectExtend = 48;
//                CardCameraActivity.buttonDesc = "使用";
//                CardCameraActivity.topDesc = "请将证件放入框内，并对其四周边框";
                CardCameraActivity.open(mActivity,
                        true, isFront == null ? false : isFront, languageType, new CardCameraActivity.ICameraTakeListener() {
                            @Override
                            public void onCameraPictured(boolean isPositive, String fileName, String fileNameHead) {
                                ImoLog.d(isPositive);
                                ImoLog.d(fileName + "");
                                ImoLog.d(fileNameHead + "");
                                map.put("code", 200);
                                map.put("image", fileName);
                                map.put("headImage", fileNameHead);
                                mResult.success(map);
                            }

                            @Override
                            public void onUserCancel() {
                                mActivity.runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("code", -1);
                                        mResult.success(map);
                                    }
                                });
                            }
                        });
                break;
            }
            case "cleanCache": {
                FileUtils.deleteAllInDir(new File(mActivity.getCacheDir(), "cacheBitmap"));
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 保存人脸信息到本地
     *
     * @param userId
     * @param email
     * @param mobile
     * @param faceToken
     * @param faceImage
     */
    private void saveFaceToLocal(final String userId, final String email, final String mobile, final String faceToken, final String faceImage) {
        final Map<String, Object> map = new HashMap<>();
        IMoBridge.init((Application) mContext, imoKey, new IMoBridge.IImoInitListener() {
            @Override
            public void onSuccess() {
                IMoRecognitionManager.getInstance().init(SettingConfig.getAlgorithmNumThread(), new IMoRecognitionManager.InitListener() {
                    @Override
                    public void onSucceed() {
                        Bitmap bitmap = BitmapUtils.getOriginBitmap(faceImage);
                        float[] faceFeature = IMoBridge.getBitmapFeature(bitmap);

                        UserFaceBean userFace = new UserFaceBean();
                        userFace.setUid(userId);
                        userFace.setEmail(email);
                        userFace.setMobile(mobile);
                        userFace.setFaceToken(faceToken);
                        userFace.setFeature(ByteConvert.convert(faceFeature));

                        try {
                            DatabaseHelper.getInstance(mContext).getDaoSession().insert(userFace);
                            map.put("code", 200);
                        } catch (Exception e) {
                            Log.d("TAG", e.getMessage());
                            e.printStackTrace();
                            map.put("code", -1);
                        } finally {
                            // 释放爱莫资源
                            IMoBridge.release();
                            mActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    mResult.success(map);
                                }
                            });
                        }
                    }

                    @Override
                    public void onError(int code, String msg) {
                        map.put("code", -1); // error
                        mResult.success(map);
                    }
                });
            }

            @Override
            public void onFail(int code) {
                map.put("code", -1); // error
                mResult.success(map);
            }
        });
    }

    /**
     * 更新用户faceToken
     *
     * @param userId
     * @param newFaceToken
     */
    private void updateFaceToken(String userId, String newFaceToken) {
        final Map<String, Object> map = new HashMap<>();
        DaoSession daoSession = DatabaseHelper.getInstance(mContext).getDaoSession();
        List<UserFaceBean> userFaces =
                daoSession.getUserFaceBeanDao().queryBuilder()
                        .where(UserFaceBeanDao.Properties.Uid.eq(userId)).limit(1).list();
        if (userFaces != null && userFaces.size() > 0) {
            UserFaceBean userFace = userFaces.get(0);
            userFace.setFaceToken(newFaceToken);
            daoSession.getUserFaceBeanDao().update(userFace);

            map.put("code", 200);
            mResult.success(map);
            return;
        }
        map.put("code", -1); // error
        mResult.success(map);
    }

    /**
     * 删除用户人脸数据
     *
     * @param faceToken 人脸token
     */
    private void deleteFaceToken(String faceToken) {
        final Map<String, Object> map = new HashMap<>();
        DaoSession daoSession = DatabaseHelper.getInstance(mContext).getDaoSession();
        List<UserFaceBean> userFaces =
                daoSession.getUserFaceBeanDao().queryBuilder()
                        .where(UserFaceBeanDao.Properties.FaceToken.eq(faceToken)).limit(1).list();
        if (userFaces != null && userFaces.size() > 0) {
            UserFaceBean userFace = userFaces.get(0);
            daoSession.getUserFaceBeanDao().deleteByKey(userFace.getId());
            map.put("code", 200);
            mResult.success(map);
            return;
        }
        map.put("code", -1);
        mResult.success(map);
    }

    /**
     * 删除所有人脸信息
     */
    private void deleteAllUserFace() {
        final Map<String, Object> map = new HashMap<>();
        DaoSession daoSession = DatabaseHelper.getInstance(mContext).getDaoSession();
        daoSession.getUserFaceBeanDao().deleteAll();
        map.put("code", 200);
        mResult.success(map);
    }

    /**
     * 图片相似度对比
     *
     * @param originImage  原图
     * @param targetImages 对比图
     */
    private void faceSimilarityComparison(final String originImage, final List<String> targetImages) {
        final Map<String, Object> map = new HashMap<>();
        IMoBridge.init((Application) mContext, imoKey, new IMoBridge.IImoInitListener() {
            @Override
            public void onSuccess() {
                IMoRecognitionManager.getInstance().init(SettingConfig.getAlgorithmNumThread(), new IMoRecognitionManager.InitListener() {
                    @Override
                    public void onSucceed() {
                        try {
                            Bitmap originBitmap = BitmapUtils.getOriginBitmap(originImage);
                            ArrayList<Bitmap> targetBitmaps = new ArrayList<>();
                            for (String path : targetImages) {
                                targetBitmaps.add(BitmapUtils.getOriginBitmap(path));
                            }

                            float maxScore = IMoBridge.faceSimilarityComparison(originBitmap, targetBitmaps);

                            map.put("code", 200);
                            map.put("score", maxScore);
                        } catch (Exception e) {
                            map.put("code", -1); // error
                        } finally {
                            // 释放爱莫资源
                            IMoBridge.release();
                            mActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    mResult.success(map);
                                }
                            });
                        }
                    }

                    @Override
                    public void onError(int code, String msg) {
                        map.put("code", -1); // error
                        mResult.success(map);
                    }
                });
            }

            @Override
            public void onFail(int code) {
                map.put("code", -1); // error
                mResult.success(map);
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            // 动作活体采集
            case RESULT_ACTION_LIVING: {
                Map<String, Object> map = new HashMap<>();
                if (resultCode == Activity.RESULT_CANCELED) {
                    map.put("code", -1); // 用户主动取消
                } else {
                    map.put("code", 200);
                    map.put("image", data.getStringExtra("image"));
                }
                mResult.success(map);
            }
            break;
            // 实名认证采集
            case RESULT_CERT_LIVING: {
                Map<String, Object> map = new HashMap<>();
                if (resultCode == Activity.RESULT_CANCELED) {
                    map.put("code", -1); // 用户主动取消
                } else {
                    map.put("code", 200);
                    map.put("image1", data.getStringExtra("image1"));
                    map.put("image2", data.getStringExtra("image2"));
                    map.put("image3", data.getStringExtra("image3"));
                    map.put("video", data.getStringExtra("video"));
                }
                mResult.success(map);
            }
            break;
            // 静默采集
            case RESULT_SILENT_LIVING: {
                Map<String, Object> map = new HashMap<>();
                if (resultCode == Activity.RESULT_CANCELED) {
                    map.put("code", -1); // 用户主动取消
                } else {
                    map.put("code", 200);
                    map.put("image", data.getStringExtra("image"));
                    map.put("faceToken", data.getStringExtra("faceToken"));
                }
                mResult.success(map);
            }
            break;
            default:
        }
        return false;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
        IMoBridge.initEasyLibUtilsx(mActivity.getApplication());
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        mActivity = null;
    }
}
