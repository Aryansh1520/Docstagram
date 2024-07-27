import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messagesController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messagesController.stream;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel?.stream.listen(
      (message) {
  final decodedMessage = jsonDecode(message); // Decode the entire JSON message
    final messageContent = decodedMessage['message']; // Extract the 'message' part
    _messagesController.add(messageContent); // Add only the 'message' part to the messages controller
      },
      onDone: () {
        _messagesController.close();
      },
      onError: (error) {
        _messagesController.addError(error);
      },
    );
  }

  void sendMessage(String userId, Map<String, dynamic> message) {
    final payload = jsonEncode({
      'recipient_id': userId,
      'message': message,
    });
    _channel?.sink.add(payload);
  }

  void close() {
    _channel?.sink.close();
  }
}
