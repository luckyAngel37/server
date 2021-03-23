import 'dart:io';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';

void main() async {
  var staticFileHandler =
      createStaticHandler('www', defaultDocument: 'index.html');

  var router = Router();
  router.get('/hello', _hello);
  router.get('/user/<user>', _user);

  var cascadeHandler =
      Cascade().add(staticFileHandler).add(router).add(_echoRequest).handler;

  var handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(cascadeHandler);

  var portStr = Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  var server = await io.serve(handler, '0.0.0.0', port);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _hello(Request request) {
  return Response.ok('hello, world!');
}

Response _user(Request request, String user) {
  var data = <String, dynamic>{'name': 'yao', 'group': 'ZII'};
  return Response.ok(
    json.encode(data),
    headers: {'Content-Type': 'application/json'},
  );
}

Response _echoRequest(Request request) {
  return Response.ok('Request for "${request.url}"');
}
