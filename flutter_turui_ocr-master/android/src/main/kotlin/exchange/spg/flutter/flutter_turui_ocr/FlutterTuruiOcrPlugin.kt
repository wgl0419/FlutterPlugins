package exchange.spg.flutter.flutter_turui_ocr

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.util.Log
import androidx.annotation.NonNull
import com.blankj.utilcode.util.ImageUtils
import com.blankj.utilcode.util.PathUtils
import com.idcard.TFieldID
import com.idcard.TStatus
import com.idcard.TengineID
import com.turui.android.activity.CameraActivity
import com.turui.engine.EngineConfig
import com.turui.engine.InfoCollection
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.*
import kotlin.collections.HashMap

/** FlutterTuruiOcrPlugin */
class FlutterTuruiOcrPlugin : FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener, ActivityAware {

    private val TAG = "OCRModule"

    private val REQUEST_CODE_IDCARD_FRONT = 600
    private val REQUEST_CODE_IDCARD_BACK = 700
    private val RESULT_CODE_IDCARD_FRONT = 601
    private val RESULT_CODE_IDCARD_BACK = 701

    private lateinit var channel: MethodChannel

    private var mResult: Result? = null

    private lateinit var mContext: Context
    private var mActivity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "exchange.sgp.flutter/flutter_turui_ocr")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initSdk" -> initSdk(result)
            "identify" -> identify(result = result)
            "deInitSdk" -> deInitSdk()
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initSdk(@NonNull result: Result) {
        OCRManager.initSDK(mContext);
        result.success(true);
    }

    private fun identify(isFrontOfIDCard: Boolean = true, @NonNull result: Result) {
        mResult = result;
        // 判断引擎是否初始化成功
        if (OCRManager.getInitStatus() !== TStatus.TR_OK) {
            result.success(false);
            return
        }

        val tengineID = TengineID.TIDCARD2
        val intent = Intent(mActivity, SimpleCustomUIIDCardActivity::class.java)
        val config = EngineConfig(OCRManager.getEngine(), tengineID)
        config.engingModeType = EngineConfig.EngingModeType.SCAN // 扫描模式
        config.isShowModeChange = true // 是否显示模式切换按钮
        config.isOpenSmallPicture = true // 开启小图（身份证头像与银行卡卡号其它证件没有）
        config.isSaveToData = false // 保存到私有目录
        config.setbMattingOfIdcard(true)
        config.isDecodeInRectOfTakeMode = true
        config.isHideVersionTip = true // 强制关闭测试版提示
        config.resultCode = if (isFrontOfIDCard) RESULT_CODE_IDCARD_FRONT else RESULT_CODE_IDCARD_BACK
        config.isLogcatEnable = true // 是否在控制台打印log
        intent.putExtra(EngineConfig::class.java.simpleName, config) // 必须有
        mActivity?.startActivityForResult(intent, if (isFrontOfIDCard) REQUEST_CODE_IDCARD_FRONT else REQUEST_CODE_IDCARD_BACK)
    }

    private fun deInitSdk() {
        OCRManager.deinit();
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_IDCARD_FRONT ||
                requestCode == REQUEST_CODE_IDCARD_BACK) {
            Log.d(TAG, "handleActivityResult: requestCode$requestCode - resultCode: $resultCode")
            if (Activity.RESULT_CANCELED == resultCode) {
                mResult?.success(false)
                return true
            }

            val bundle = data!!.extras
            val info = bundle!!.getSerializable("info") as InfoCollection?
            Log.d(TAG, "handleActivityResult: " + info!!.allinfo)

            val map: MutableMap<String, Any> = HashMap()
            when (info.idCardType) {
                InfoCollection.IDCardType.IDFRONT -> {
                    map["isFront"] = true
                    val realName = info.getFieldString(TFieldID.NAME)
                    val idCardNo = info.getFieldString(TFieldID.NUM)
                    map["realName"] = realName
                    map["idCardNum"] = idCardNo
                }
                InfoCollection.IDCardType.IDBACK -> {
                    map["isFront"] = false
                }
                else -> {
                    return true;
                }
            }

            val cachePath: String = PathUtils.getInternalAppCachePath()
            //全图
            //全图
            if (CameraActivity.takeBitmap != null && !CameraActivity.takeBitmap.isRecycled) {
                val cardImageName = UUID.randomUUID().toString() + ".jpg"
                val smallImage: Bitmap = ImageUtils.compressBySampleSize(CameraActivity.takeBitmap, 800, 600)
                val imagePath = "$cachePath/cardImage/$cardImageName";

                ImageUtils.save(smallImage, imagePath, Bitmap.CompressFormat.JPEG);
                map["image"] = imagePath
            }
            //身份证头像与银行卡小图，其它证件没有这个
            //身份证头像与银行卡小图，其它证件没有这个
            if (CameraActivity.smallBitmap != null && !CameraActivity.smallBitmap.isRecycled) {
                val cardHeadImageName = UUID.randomUUID().toString() + ".jpg"
                val smallImage: Bitmap = ImageUtils.compressBySampleSize(CameraActivity.smallBitmap, 300, 300)
                val imagePath = "$cachePath/cardImage/$cardHeadImageName";
                ImageUtils.save(smallImage, imagePath, Bitmap.CompressFormat.JPEG);
                map["headImage"] = imagePath
            }

            mResult?.success(map);
            mResult = null;
        }
        return true;
    }

    override fun onDetachedFromActivity() {
        mActivity = null;
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}
