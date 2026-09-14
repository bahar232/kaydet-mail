part of 'compose_cubit.dart';

enum ComposeStatus { editing, sending, sent, draftSaved, error }

class ComposeState extends Equatable {
  final String id;
  final String to;
  final String cc;
  final String bcc;
  final String subject;
  final String body;
  final ComposeStatus status;
  final Email? result;

  const ComposeState({
    this.id = '',
    this.to = '',
    this.cc = '',
    this.bcc = '',
    this.subject = '',
    this.body = '',
    this.status = ComposeStatus.editing,
    this.result,
  });

  ComposeState copyWith({
    String? id,
    String? to,
    String? cc,
    String? bcc,
    String? subject,
    String? body,
    ComposeStatus? status,
    Email? result,
  }) {
    return ComposeState(
      id: id ?? this.id,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      status: status ?? this.status,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [id, to, cc, bcc, subject, body, status, result];
}
