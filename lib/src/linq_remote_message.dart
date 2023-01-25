
import 'linq_remote_notification.dart';

class LinqRemoteMessage {

  // ignore: public_member_api_docs


  LinqRemoteMessage({this.twi_message_type, this.author, this.message_index, this.message_sid,
    this.conversation_sid, this.twi_message_id, this.conversation_title});

  final String? twi_message_type;
  final String? author;
  final int? message_index;
  final String? message_sid;
  final String? conversation_sid;
  final String? twi_message_id;
  final String? conversation_title;


  /// Constructs a [RemoteMessage] from a raw Map.
  factory LinqRemoteMessage.fromMap(Map<String, dynamic> map) {
    return LinqRemoteMessage(
      twi_message_type: map['twi_message_type'],
      author: map['author'],
      message_index: map['message_index'],
      message_sid: map['message_sid'],
      conversation_sid: map['conversation_sid'],
      twi_message_id: map['twi_message_id'],
      // Note: using toString on messageId as it can be an int or string when being sent from native.
      conversation_title: map['conversation_title'],

    );
  }

  /// Returns the [RemoteMessage] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'twi_message_type': twi_message_type,
      'author': author,
      'message_index': message_index,
      'message_sid': message_sid,
      'conversation_sid': conversation_sid,
      'twi_message_id': twi_message_id,
      'conversation_title': conversation_title,
    };
  }

  @override
  String toString() {
    return 'LinqRemoteMessage{twi_message_type: $twi_message_type, author: $author, message_index: $message_index, message_sid: $message_sid, conversation_sid: $conversation_sid, twi_message_id: $twi_message_id, conversation_title: $conversation_title}';
  }
}