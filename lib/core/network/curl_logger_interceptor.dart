import 'package:dio/dio.dart';

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curl = _toCurl(options);
    // ignore: avoid_print
    print(curl);
    handler.next(options);
  }

  String _toCurl(RequestOptions options) {
    final buffer = StringBuffer('curl');
    buffer.write(' -X ${options.method}');
    buffer.write(" '${options.uri}'");
    options.headers.forEach((k, v) {
      if (k != 'Cookie') buffer.write(' -H \'$k: $v\'');
    });
    if (options.data != null) {
      final data = options.data is Map || options.data is List
          ? options.data.toString()
          : options.data.toString();
      if (data.isNotEmpty) buffer.write(' -d \'$data\'');
    }
    return buffer.toString();
  }
}
