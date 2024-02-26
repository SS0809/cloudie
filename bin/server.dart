import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final _router = Router()
  ..get('/', _rootHandler)
  ..get('/read/<message>', _readHandler);


Future<Response> _readHandler(Request request) async {
  try {
    final message = request.params['message'];
    File image = File("bin/$message");
    if (!image.existsSync()) {
      return Response.notFound('Image not found');
    }

    List<int> raw = await image.readAsBytes();

    return Response.ok(raw, headers: {
      'Content-Length': raw.length.toString(),
      'Content-Type': 'image/jpeg',
    });
  } catch (e) {
    print('Error handling request: $e');
    return Response.internalServerError(body: 'Internal Server Error');
  }
}

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n', headers: {'Content-Type': 'text/plain'});
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
