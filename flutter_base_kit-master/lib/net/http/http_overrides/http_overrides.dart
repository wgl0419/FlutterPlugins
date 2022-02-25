library http_overrides;

export 'src/http_overrides_io.dart' if (dart.library.html) 'src/http_overrides_web.dart';
