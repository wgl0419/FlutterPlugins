package exchange.sgp.flutter.flutter_sgp_event_tracking;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Debug.MemoryInfo;

import java.lang.reflect.Method;

/**
 * 内存信息工具类。
 */
public class MemUtils {

    /**
     * 获取内存信息：total、free、buffers、cached，单位MB
     *
     * @return 内存信息
     */
    public static long[] getMemInfo() {
        long memInfo[] = new long[4];
        try {
            Class<?> procClazz = Class.forName("android.os.Process");
            Class<?> paramTypes[] = new Class[]{String.class, String[].class,
                    long[].class};
            Method readProclines = procClazz.getMethod("readProcLines",
                    paramTypes);
            Object args[] = new Object[3];
            final String[] memInfoFields = new String[]{"MemTotal:",
                    "MemFree:", "Buffers:", "Cached:"};
            long[] memInfoSizes = new long[memInfoFields.length];
            memInfoSizes[0] = 30;
            memInfoSizes[1] = -30;
            args[0] = new String("/proc/meminfo");
            args[1] = memInfoFields;
            args[2] = memInfoSizes;
            if (null != readProclines) {
                readProclines.invoke(null, args);
                for (int i = 0; i < memInfoSizes.length; i++) {
                    memInfo[i] = memInfoSizes[i];
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return memInfo;
    }

    /**
     * 获取空闲内存
     *
     * @return 空闲内存
     */
    public static long getFreeMem() {
        long[] memInfo = getMemInfo();
        return memInfo[1] + memInfo[2] + memInfo[3];
    }

    /**
     * 获取总内存
     *
     * @return 总内存
     */
    public static long getTotalMem() {
        long[] memInfo = getMemInfo();
        return memInfo[0];
    }

    /**
     * 获取进程内存Private Dirty数据
     *
     * @param context
     * @param pid     进程ID
     * @return nativePrivateDirty、dalvikPrivateDirty、 TotalPrivateDirty
     */
    public static long[] getPrivDirty(Context context, int pid) {

        ActivityManager mAm = (ActivityManager) context
                .getSystemService(Context.ACTIVITY_SERVICE);
        int[] pids = new int[1];
        pids[0] = pid;
        MemoryInfo[] memoryInfoArray = mAm.getProcessMemoryInfo(pids);
        MemoryInfo pidMemoryInfo = memoryInfoArray[0];
        long[] value = new long[3]; // Natvie Dalvik Total
        value[0] = pidMemoryInfo.nativePrivateDirty;
        value[1] = pidMemoryInfo.dalvikPrivateDirty;
        value[2] = pidMemoryInfo.getTotalPrivateDirty();
        return value;
    }
}