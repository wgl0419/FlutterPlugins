import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/widgets/load_image.dart';

///输入框使用案例
///  keyboardType: TextInputType.number,  键盘类型
///  inputFormattersType: InputFormattersType.doubleNumber,  输入限制条件
///  digit: 1.toCoinKeepNum('AITD'),  //允许输入的小数位数， InputFormattersType 是 doubleNumber起作用
///  max: canUseNum,     //允许输入的最大数， 用于限制输入数量不大于可用余额

/// 登录模块的输入框封装
class MyTextField extends StatefulWidget {
  const MyTextField({
    Key? key,
    required this.controller,
    this.maxLength = 100,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.hintText = '',
    this.labelText = '',
    this.focusNode,
    this.isInputPwd = false,
    this.getVCode,
    this.rightBtn,
    this.leftWidget,
    this.keyName,
    this.digit = 8,
    this.max = 10000000000000000000,
  }) : super(key: key);

  final TextEditingController controller;
  final int maxLength;
  final bool autoFocus;
  final TextInputType keyboardType;
  final String hintText;
  final String labelText;
  final FocusNode? focusNode;
  final bool isInputPwd;
  final Widget? leftWidget;
  final Future<bool> Function()? getVCode;
  final Widget? rightBtn;

  final int digit; //允许输入的小数位数， InputFormattersType 是 doubleNumber起作用
  final double max;

  /// 用于集成测试寻找widget
  final String? keyName;

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isShowPwd = false;
  bool _isShowDelete = false;
  bool _isFocus = false;

  StreamSubscription? _subscription;

  @override
  void initState() {
    /// 获取初始化值
    _isShowDelete = widget.controller.text.isEmpty;

    /// 监听输入改变
    widget.controller.addListener(isEmpty);

    widget.focusNode?.addListener(isFocus);

    super.initState();
  }

  void isFocus() {
    final bool? isFocus = widget.focusNode?.hasFocus;
    if (_isFocus != isFocus) {
      setState(() {
        _isFocus = isFocus!;
      });
    }
  }

  void isEmpty() {
    final bool isEmpty = widget.controller.text.isEmpty;

    /// 状态不一样在刷新，避免重复不必要的setState
    if (isEmpty != _isShowDelete) {
      setState(() {
        _isShowDelete = isEmpty;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.controller.removeListener(isEmpty);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextField textField = TextField(
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      focusNode: widget.focusNode,
      maxLength: widget.maxLength,
      // ignore: avoid_bool_literals_in_conditional_expressions
      obscureText: widget.isInputPwd ? !_isShowPwd : false,
      autofocus: widget.autoFocus,
      controller: widget.controller,
      textInputAction: TextInputAction.done,
      keyboardType: widget.keyboardType,
      enableInteractiveSelection: true,
      decoration: InputDecoration(
        prefixIcon: widget.leftWidget,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        hintText: widget.hintText,
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        counterText: '',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.8,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.8,
          ),
        ),
      ),
    );
    final Widget clear = Semantics(
      label: '清空',
      hint: '清空输入框',
      child: GestureDetector(
        child: const Icon(
          Icons.clear_rounded,
          size: 20,
          color: Colors.grey,
        ),
        onTap: () => widget.controller.text = '',
      ),
    );

    final Widget pwdVisible = Semantics(
      label: '密码可见开关',
      hint: '密码是否可见',
      child: GestureDetector(
        child: LoadAssetImage(
          _isShowPwd ? 'login/qyg_shop_icon_display' : 'login/qyg_shop_icon_hide',
          key: Key('${widget.keyName}_showPwd'),
          width: 18.0,
          height: 40.0,
        ),
        onTap: () {
          setState(() {
            _isShowPwd = !_isShowPwd;
          });
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.labelText, style: TextStyle(color: _isFocus ? Colors.black : Colors.black)),
        Stack(
          alignment: Alignment.centerRight,
          children: <Widget>[
            textField,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!_isShowDelete && _isFocus) clear else const SizedBox(),
                if (!widget.isInputPwd)
                  const SizedBox()
                else
                  const SizedBox(
                    width: 15,
                  ),
                if (!widget.isInputPwd) const SizedBox() else pwdVisible,
                if (widget.getVCode == null)
                  const SizedBox()
                else
                  const SizedBox(
                    width: 15,
                  ),
                if (widget.rightBtn == null) const SizedBox() else widget.rightBtn!,
              ],
            )
          ],
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }
}
