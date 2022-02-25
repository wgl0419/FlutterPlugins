package exchange.sgp.flutter.flutter_sgp_event_tracking;

import java.math.BigDecimal;

public class DoubleUtils {
    /**
     * double 乘法
     *
     * @param d1
     * @param d2
     * @return
     */
    public static double mul(double d1, double d2) {
        BigDecimal bd1 = new BigDecimal(Double.toString(d1));
        BigDecimal bd2 = new BigDecimal(Double.toString(d2));

        try
        {
            return bd1.multiply(bd2).doubleValue();
        } catch (Exception e)
        {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * double 除法
     *
     * @param d1
     * @param d2
     * @param scale
     * @return
     */
    public static double div(double d1, double d2, int scale) {
        BigDecimal bd1 = new BigDecimal(Double.toString(d1));
        BigDecimal bd2 = new BigDecimal(Double.toString(d2));
        try
        {
            return bd1.divide(bd2, scale, BigDecimal.ROUND_DOWN).doubleValue();
        } catch (Exception e)
        {
            e.printStackTrace();
            return 0;
        }

    }

}