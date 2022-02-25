import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dimens.dart';

/// 间隔
class Gaps {
  /// 水平间隔
  static Widget hGap1 = SizedBox(width: Dimens.gapDp1.sp);
  static Widget hGap3 = SizedBox(width: Dimens.gapDp3.sp);
  static Widget hGap4 = SizedBox(width: Dimens.gapDp4.sp);
  static Widget hGap5 = SizedBox(width: Dimens.gapDp5.sp);
  static Widget hGap8 = SizedBox(width: Dimens.gapDp8.sp);
  static Widget hGap10 = SizedBox(width: Dimens.gapDp10.sp);
  static Widget hGap12 = SizedBox(width: Dimens.gapDp12.sp);
  static Widget hGap14 = SizedBox(width: Dimens.gapDp14.sp);
  static Widget hGap15 = SizedBox(width: Dimens.gapDp15.sp);
  static Widget hGap16 = SizedBox(width: Dimens.gapDp16.sp);
  static Widget hGap20 = SizedBox(width: Dimens.gapDp20.sp);
  static Widget hGap32 = SizedBox(width: Dimens.gapDp32.sp);
  static Widget hGap34 = SizedBox(width: Dimens.gapDp34.sp);
  static Widget hGap42 = SizedBox(width: Dimens.gapDp42.sp);
  static Widget hGap47 = SizedBox(width: Dimens.gapDp47.sp);
  static Widget hGap24 = SizedBox(width: Dimens.gapDp24.sp);

  /// 垂直间隔
  static Widget vGap0 = SizedBox(height: Dimens.gapDp0.sp);
  static Widget vGap4 = SizedBox(height: Dimens.gapDp4.sp);
  static Widget vGap5 = SizedBox(height: Dimens.gapDp5.sp);
  static Widget vGap8 = SizedBox(height: Dimens.gapDp8.sp);
  static Widget vGap10 = SizedBox(height: Dimens.gapDp10.sp);
  static Widget vGap12 = SizedBox(height: Dimens.gapDp12.sp);
  static Widget vGap13 = SizedBox(height: Dimens.gapDp13.sp);
  static Widget vGap14 = SizedBox(height: Dimens.gapDp14.sp);
  static Widget vGap15 = SizedBox(height: Dimens.gapDp15.sp);
  static Widget vGap16 = SizedBox(height: Dimens.gapDp16.sp);
  static Widget vGap18 = SizedBox(height: Dimens.gapDp18.sp);
  static Widget vGap20 = SizedBox(height: Dimens.gapDp20.sp);
  static Widget vGap24 = SizedBox(height: Dimens.gapDp24.sp);
  static Widget vGap32 = SizedBox(height: Dimens.gapDp32.sp);
  static Widget vGap50 = SizedBox(height: Dimens.gapDp50.sp);
  static Widget vGap34 = SizedBox(height: Dimens.gapDp34.sp);
  static Widget vGap42 = SizedBox(height: Dimens.gapDp42.sp);
  static Widget vGap47 = SizedBox(height: Dimens.gapDp47.sp);

  static const Widget line = Divider();

  static const Widget vLine = SizedBox(
    width: 0.6,
    height: 24.0,
    child: VerticalDivider(),
  );

  /// 垂直线
  static Widget vvLine({double? width, double? height, Color? color}) {
    if (color != null) {
      return SizedBox(
        width: width ?? 0.6,
        height: height ?? 24.0,
        child: VerticalDivider(color: color),
      );
    } else {
      return SizedBox(
        width: width ?? 0.6,
        height: height ?? 24.0,
        child: const VerticalDivider(),
      );
    }
  }

  static Widget hhLine({double? width, double? height, Color? color}) {
    if (color != null) {
      return SizedBox(
        width: width,
        height: height,
        child: Divider(color: color),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: const Divider(),
      );
    }
  }

  static const Widget empty = SizedBox.shrink();
}
