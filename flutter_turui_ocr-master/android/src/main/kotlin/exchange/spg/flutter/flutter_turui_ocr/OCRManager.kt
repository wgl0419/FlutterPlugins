package exchange.spg.flutter.flutter_turui_ocr

import android.content.Context
import android.util.Log
import com.idcard.TRECAPI
import com.idcard.TRECAPIImpl
import com.idcard.TStatus
import java.util.*


object OCRManager {
    private lateinit var engine: TRECAPI
    private var initStatus: TStatus? = null
    private const val TAG = "OCRManager"

    fun getInitStatus(): TStatus? {
        return initStatus
    }

    fun getEngine(): TRECAPI {
        return engine;
    }

    fun initSDK(context: Context) {
        Log.d(TAG, "开始初始化OCR.....")
        if (initStatus == TStatus.TR_OK) {
            return;
        }
        val now: Long = Date().time
        initStatus = engine.TR_StartUP(context, engine.TR_GetEngineTimeKey()) // 正式版用这句，且替换正式版 .so .dat .mdl文件
        val end: Long = Date().time
        Log.e(TAG, "OCRManager: 引擎初始化时间111: " + (end - now) + "ms")
        if (null == initStatus) {
            Log.e(TAG, "引擎初始化异常\r\nOCR引擎版本 >=7.4.0 的请检查工程assets文件夹下是否包含对应几个文件\r\nlicense.dat\r\noption.cfg\r\ntrData.mdl")
        } else if (initStatus === TStatus.TR_TIME_OUT) {
            // 版本号 >= 7.4.0 时 TR_StartUP(context, 时间Key不再起作用可以任意传，具体配置改到了 assets 下的 license.dat 中)
            Log.e(TAG, "initSDK: 引擎时间过期")
        } else if (initStatus === TStatus.TR_FAIL) {
            Log.e(TAG, "initSDK: 引擎初始化失败")
        } else if (initStatus === TStatus.TR_BUILD_ERR) {
            Log.e(TAG, "initSDK: 包名绑定不一致")
        } else if (initStatus === TStatus.TR_OK) {
            Log.d(TAG, "initSDK: 引擎初始化正常")
        } else {
            Log.e(TAG, "错误：" + initStatus!!.name)
        }
        val time: String = engine.TR_GetUseTimeString() ?: "";
        Log.d(TAG, "OCR授权版本: $time")
    }

    fun deinit() {
        engine.TR_ClearUP()
        initStatus = null;
    }

    init {
        try {
            engine = TRECAPIImpl()
            Log.d(TAG, "引擎开始初始化!!!!!!!!!!!!!!!!!!!!!!")
        } catch (e: UnsatisfiedLinkError) {
            e.printStackTrace()
            val message = e.message
            Log.e(TAG, "initSDK: " + String.format("OCR版本类型：%s\r\nOCR引擎版本：%s", "初始化异常", "初始化异常"))
            Log.e(TAG, """
     initSDK: 识别引擎加载 libIDCARDDLL.so 文件失败，请检查工程libs下是否有对应文件
     libs/armeabi/libIDCARDDLL.so 或其它架构so文件
     """.trimIndent())
            Log.e(TAG, "\ninitSDK: 错误信息:$message")
        }
    }
}
