package exchange.sgp.flutter.flutter_sgp_event_tracking;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterSgpEventTrackingPlugin
 */
public class FlutterSgpEventTrackingPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private Context mContext;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_sgp_event_tracking");
        channel.setMethodCallHandler(this);
        mContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
        if (call.method.equals("getDeviceInfo")) {

            final Map<String, Object> map = new HashMap<>();
            map.put("deviceName", CpuUtils.getCpuName());
            map.put("cpuUsage", 0.0);
            map.put("appCPUUsage", 0.0);

            map.put("memoryUsed", MemUtils.getTotalMem() - MemUtils.getFreeMem());
            map.put("memoryTotal", MemUtils.getTotalMem());
            map.put("memoryFree", MemUtils.getFreeMem());
            map.put("appUsedMemory", MemUtils.getPrivDirty(mContext, android.os.Process.myPid())[2] / 1024 * 1.0);

            map.put("usedDiskSpace", StorageUtils.getSDCardMemory()[2]);
            map.put("freeDiskSpace", StorageUtils.getSDCardMemory()[1]);
            map.put("totalDiskSpace", StorageUtils.getSDCardMemory()[0]);

            AppSizeUtils.getInstance().setDatasListent(new AppSizeUtils.OnBackListent() {
                @Override
                public void backData(long cacheSize, long dataSize, long codeSize) {
                    map.put("appSize", cacheSize + dataSize + codeSize);
                    result.success(map);
                }
            }).init(mContext);

        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
