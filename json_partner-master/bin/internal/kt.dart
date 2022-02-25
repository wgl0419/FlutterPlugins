/// 类似kotlin语法的dart扩展
extension KtExtensions<T> on T {
  /// 类型装换
  R let<R>(R Function(T it) fn) => fn(this);

  /// 对本身做一系列的操作然后返回本身
  T also(Function(T it) fn) {
    fn(this);
    return this;
  }
}
