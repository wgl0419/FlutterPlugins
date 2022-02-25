package exchange.sgp.flutter_aimall_face_recognition.data;

import android.content.Context;

import org.greenrobot.greendao.database.Database;
import org.greenrobot.greendao.query.QueryBuilder;

import exchange.sgp.flutter_aimall_face_recognition.BuildConfig;
import exchange.sgp.flutter_aimall_face_recognition.db.DaoMaster;
import exchange.sgp.flutter_aimall_face_recognition.db.DaoSession;

/**
 * 数据库管理者 - 提供数据库封装
 */
public class DatabaseHelper {
    private static final String TAG = DatabaseHelper.class.getSimpleName();
    private volatile static DatabaseHelper mInstance;
    private final DaoSession daoSession;
    private final static String dbPwd = "exchange.sgp.face.20201228";

    private DatabaseHelper(Context context) {
        DaoMaster.DevOpenHelper helper = new DaoMaster.DevOpenHelper(context, "exchange.sgp.face.db");
        Database db = helper.getEncryptedWritableDb(dbPwd);
        DaoMaster daoMaster = new DaoMaster(db);
        daoSession = daoMaster.newSession();
        //sql日志
        QueryBuilder.LOG_SQL = BuildConfig.DEBUG;
        QueryBuilder.LOG_VALUES = BuildConfig.DEBUG;
    }

    public static DatabaseHelper getInstance(Context context) {
        DatabaseHelper inst = mInstance;
        if (inst == null) {
            synchronized (DatabaseHelper.class) {
                inst = mInstance;
                if (inst == null) {
                    inst = new DatabaseHelper(context);
                    mInstance = inst;
                }
            }
        }
        return inst;
    }

    public DaoSession getDaoSession() {
        return daoSession;
    }
}
