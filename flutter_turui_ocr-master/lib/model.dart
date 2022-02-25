import 'dart:io';

/// OCR 返回的信息
class OCRResultInfo {
  /// 是否为正面
  bool? isFront;

  /// 身份证正面信息
  ///
  /// 当 [isFront] 为 true 时 有效;
  FrontCardInfo? frontCardInfo;

  /// 身份证背面信息
  ///
  /// 当 [isFront] 为 false 时 有效;
  BackCardInfo? backCardInfo;

  OCRResultInfo(this.isFront, {this.frontCardInfo, this.backCardInfo});

  OCRResultInfo.fromJson(Map json) {
    if (json.containsKey('isFront')) {
      isFront = json['isFront'];
    }

    if (isFront ?? false) {
      frontCardInfo = FrontCardInfo.fromJson(json);
    } else {
      backCardInfo = BackCardInfo.fromJson(json);
    }
  }

  @override
  String toString() {
    return 'OCRResultInfo{isFront: $isFront, frontCardInfo: $frontCardInfo, backCardInfo: $backCardInfo}';
  }
}

/// 卡片正面信息
class FrontCardInfo {
  FrontCardInfo(this.realName, this.idCardNum, this.image, this.headImage);

  /// 真实姓名
  String? realName;

  /// 身份证号
  String? idCardNum;

  /// 身份证图片
  File? image;

  /// 身份证头像
  File? headImage;

  FrontCardInfo.fromJson(Map json) {
    if (json.containsKey('realName')) {
      realName = json['realName'];
    }

    if (json.containsKey('idCardNum')) {
      idCardNum = json['idCardNum'];
    }
    if (json.containsKey('image')) {
      image = File(json['image']);
    }

    if (json.containsKey('headImage')) {
      headImage = File(json['headImage']);
    }
  }

  @override
  String toString() {
    return 'FrontCardInfo{realName: $realName, idCardNum: $idCardNum, image: ${image?.lengthSync()}, headImage: $headImage}';
  }
}

/// 背面信息
class BackCardInfo {
  BackCardInfo({this.image});

  /// 身份证图片
  File? image;

  BackCardInfo.fromJson(Map json) {
    if (json.containsKey('image')) {
      image = File(json['image']);
    }
  }

  @override
  String toString() {
    return 'BackCardInfo{image: $image}';
  }
}
