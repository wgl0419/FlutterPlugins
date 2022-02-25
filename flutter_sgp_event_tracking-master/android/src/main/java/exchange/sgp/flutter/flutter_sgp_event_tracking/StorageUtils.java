package exchange.sgp.flutter.flutter_sgp_event_tracking;

import android.os.Environment;
import android.os.StatFs;

import java.io.File;

public class StorageUtils {
    public static long[] getSDCardMemory() {
        long[] sdCardInfo = new long[3];
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state)) {
            File sdcardDir = Environment.getExternalStorageDirectory();
            StatFs sf = new StatFs(sdcardDir.getPath());
            long bSize = sf.getBlockSizeLong();
            long bCount = sf.getBlockCountLong();
            long availBlocks = sf.getAvailableBlocksLong();

            sdCardInfo[0] = bSize * bCount;//总大小
            sdCardInfo[1] = bSize * availBlocks;//可用大小
            sdCardInfo[2] = bSize * (bCount - availBlocks);//已用大小
        }
        return sdCardInfo;
    }
}
