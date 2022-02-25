package exchange.spg.flutter.flutter_turui_ocr

import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Point
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import com.idcard.TengineID
import com.turui.android.activity.CameraActivity
import com.turui.android.cameraview.FinderView
import com.turui.engine.EngineConfig
import com.turui.engine.InfoCollection

class SimpleCustomUIIDCardActivity : CameraActivity() {

    override fun getCustomContentView(): Int {
        //已经有的控件名称等不能变，增加自己要的控件并处理就行了，除非全部自定义
        return R.layout.activity_simple_customui_idcard
    }

    override fun initBaseView() {
        super.initBaseView() //调用默认的控件设置等
        setTipBitmatToRect(cameraView.finderView, engineConfig.tipBitmapType)
    }

    /**
     * 成功，并不是指一定有数据，只是流程上的成功，还是要检查识别结果
     *
     * @param mode
     * @param infoCollection
     * @return 是否结束
     */
    override fun decodeSuccess(mode: EngineConfig.EngingModeType, infoCollection: InfoCollection): Boolean {
        Log.d(TAG, "decodeSuccess: decodeSuccess")
        if (mode == EngineConfig.EngingModeType.TAKE && tipDialog != null && tipDialog.isShowing) {
            tipDialog.dismiss()
        }

        Log.d(TAG, "" + infoCollection.allinfo)
        val intent: Intent = this.intent
        val bundle = Bundle()
        bundle.putSerializable("info", infoCollection)
        intent.putExtras(bundle)
        this.setResult(engineConfig.resultCode, intent)
        this.finish()
        return true
    }

    /**
     * 失败
     *
     * @param mode
     * @return 是否结束
     */
    override fun decodeFail(mode: EngineConfig.EngingModeType): Boolean {
        if (mode == EngineConfig.EngingModeType.TAKE && tipDialog != null && tipDialog.isShowing) {
            tipDialog.dismiss()
        }
        return if (mode == EngineConfig.EngingModeType.TAKE) {
            this.finish()
            true
        } else {
            false
        }
    }

    /**
     * 异常
     *
     * @param mode
     * @param e
     */
    protected fun decodeException(mode: EngineConfig.EngingModeType?, e: Exception?) {}

    /**
     * 设置框内提示图片
     * 暂时只增加身份证正反面提示图片
     *
     * @param finderView
     * @return
     */
    private fun setTipBitmatToRect(finderView: FinderView, type: EngineConfig.TipBitmapType): FinderView {
        if (tengineID != TengineID.TIDCARD2) {
            return finderView
        }
        var resid = 0
        if (null != engineConfig && engineConfig.tipBitmapType != EngineConfig.TipBitmapType.NONE) {
            resid = if (type == EngineConfig.TipBitmapType.IDCARD_PORTRAIT) {
                R.drawable.tip_idcard_portrait
            } else if (type == EngineConfig.TipBitmapType.IDCARD_EMBLEM) {
                R.drawable.tip_idcard_emblem
            } else {
                return finderView
            }
        }
        try {
            val res: Resources = this.resources
            val bmp = BitmapFactory.decodeResource(res, resid)
            finderView.tipBitmapToRect = bmp
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return finderView
    }

    /**
     * 获取屏幕分辨率
     *
     * @param context context
     * @return
     */
    override fun getScreenResolution(context: Context): Point {
        //反射获取
        val point = Point()
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = windowManager.defaultDisplay
        val displayMetrics = DisplayMetrics()
        val c: Class<*>
        try {
            c = Class.forName("android.view.Display")
            val method = c.getMethod("getRealMetrics", DisplayMetrics::class.java)
            method.invoke(display, displayMetrics)
            point.x = displayMetrics.widthPixels
            point.y = displayMetrics.heightPixels
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return point
    }

    /**
     * 修改框大小
     *
     * @param finderView
     * @return
     */
    override fun setWidthHeight(finderView: FinderView): FinderView {
        var pbw = 66
        if (requestedOrientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            val size = getScreenResolution(this)
            val max = size.x.coerceAtLeast(size.y)
            val min = size.x.coerceAtMost(size.y)
            val ratio = max.toFloat() / min
            if (ratio > 1.78f) { //在长屏幕机型有可能会太高，改小点
                pbw = 60
            }
        }
        if (tengineID == TengineID.TIDLPR) {
            finderView.setmIsShowAlignmentLine(false)
            finderView.rectCenterXPercent = 50
            finderView.rectCenterYPercent = 60
            finderView.rectPortraitWidthPercent = 60
            finderView.rectPortraitHeightPercentByWidth = 55
            finderView.rectLandscapeWidthPercent = 35
            finderView.rectLandscapeHeightPercentByWidth = 55
        } else if (tengineID == TengineID.TIDJSZCARD) {
            finderView.rectPortraitWidthPercent = 85
            finderView.rectPortraitHeightPercentByWidth = 67
            finderView.rectLandscapeWidthPercent = pbw + 2
            finderView.rectLandscapeHeightPercentByWidth = 67
        } else if (tengineID == TengineID.TIDXSZCARD) {
            finderView.rectPortraitWidthPercent = 85
            finderView.rectPortraitHeightPercentByWidth = 67
            finderView.rectLandscapeWidthPercent = pbw + 2
            finderView.rectLandscapeHeightPercentByWidth = 67
        } else if (tengineID == TengineID.TIDBIZLIC) {
            finderView.rectCenterXPercent = 50
            finderView.rectCenterYPercent = 50
            finderView.rectPortraitWidthPercent = 85
            finderView.rectPortraitHeightPercentByWidth = 130
            finderView.rectLandscapeWidthPercent = pbw + 2
            finderView.rectLandscapeHeightPercentByWidth = 67
        } else {
            finderView.rectCenterXPercent = 50
            finderView.rectCenterYPercent = 45
            finderView.rectPortraitWidthPercent = 85
            finderView.rectPortraitHeightPercentByWidth = 63
            finderView.rectLandscapeWidthPercent = pbw
            finderView.rectLandscapeHeightPercentByWidth = 63
        }
        if (requestedOrientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            if (tengineID != TengineID.TIDLPR) {
                finderView.rectCenterXPercent = 50
                finderView.rectCenterYPercent = 50
            }
        }
        return finderView
    }

    /**
     * 修改提示文本
     *
     * @param finderView
     * @return
     */
    override fun setTipText(finderView: FinderView): FinderView {
        if (tengineID == TengineID.TIDLPR) {
            finderView.setTipText("将车牌放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDBANK) {
            finderView.setTipText("将银行卡放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDCARD2) {
            finderView.setTipText("将身份证放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDXSZCARD) {
            finderView.setTipText("将行驶证放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDJSZCARD) {
            finderView.setTipText("将驾驶证放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDTICKET) {
            finderView.setTipText("将火车票放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDSSCCARD) {
            finderView.setTipText("将社保卡放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDPASSPORT) {
            finderView.setTipText("将护照放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDBIZLIC) {
            finderView.setTipText("将营业执照放入框内，并对齐四周边框")
        } else if (tengineID == TengineID.TIDEEPHK) {
            finderView.setTipText("将港澳通行证放入框内，并对齐四周边框")
        }
        return finderView
    }

    companion object {
        private const val TAG = "SimpleCustomUIIDCardAct"
    }
}
