package exchange.sgp.flutter_aimall_face_recognition.utils;

import com.blankj.utilcode.util.ArrayUtils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;

public final class ByteConvert {

    private static final int BYTES_IN_INT = 4;

    private ByteConvert() {
    }

    public static byte[] convert(float[] array) {
        if (ArrayUtils.isEmpty(array)) {
            return new byte[0];
        }

        return writeFloats(array);
    }

    public static float[] convert(byte[] array) {
        if (ArrayUtils.isEmpty(array)) {
            return new float[0];
        }

        return readFloats(array);
    }

    private static byte[] writeFloats(float[] array) {
        try {
            ByteArrayOutputStream bos = new ByteArrayOutputStream(array.length * 4);
            DataOutputStream dos = new DataOutputStream(bos);
            for (float v : array) {
                dos.writeFloat(v);
            }

            return bos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static float[] readFloats(byte[] array) {
        try {
            ByteArrayInputStream bis = new ByteArrayInputStream(array);
            DataInputStream dataInputStream = new DataInputStream(bis);
            int size = array.length / BYTES_IN_INT;
            float[] res = new float[size];
            for (int i = 0; i < size; i++) {
                res[i] = dataInputStream.readFloat();
            }
            return res;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
