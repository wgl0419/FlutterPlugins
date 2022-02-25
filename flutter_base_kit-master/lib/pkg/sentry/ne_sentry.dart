library bk_sentry;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base_kit/common/app_env.dart';
import 'package:flutter_base_kit/pkg/logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'src/sentry.dart';
part 'src/sentry_dio_interceptor.dart';
part 'src/sentry_manager.dart';
