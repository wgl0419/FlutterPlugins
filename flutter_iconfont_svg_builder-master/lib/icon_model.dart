class IconModel {
  final String name;
  final String viewBox;
  final List<IconPath> paths;

  const IconModel(this.name, this.viewBox, this.paths);
}

class IconPath {
  final String? color;
  final String path;

  const IconPath(this.color, this.path);
}
