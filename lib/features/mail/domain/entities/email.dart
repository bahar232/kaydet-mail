import 'package:equatable/equatable.dart';

/// Domain entity for a single mail message.
///
/// This is the shape both the mock repository and, later, the real
/// API/IMAP client should produce — screens and cubits never depend on
/// the data source, only on this entity.
class Email extends Equatable {
  final String id;
  final String folderId;
  final String from;
  final String fromEmail;
  final String? to;
  final String? cc;
  final String? bcc;
  final String subject;
  final String body;
  final String date;
  final bool read;
  final bool starred;
  final bool isPinned;
  final List<String> labels;

  const Email({
    required this.id,
    required this.folderId,
    required this.from,
    required this.fromEmail,
    this.to,
    this.cc,
    this.bcc,
    required this.subject,
    required this.body,
    required this.date,
    this.read = false,
    this.starred = false,
    this.isPinned = false,
    this.labels = const [],
  });

  Email copyWith({
    String? id,
    String? folderId,
    String? from,
    String? fromEmail,
    String? to,
    String? cc,
    String? bcc,
    String? subject,
    String? body,
    String? date,
    bool? read,
    bool? starred,
    bool? isPinned,
    List<String>? labels,
  }) {
    return Email(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      from: from ?? this.from,
      fromEmail: fromEmail ?? this.fromEmail,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      date: date ?? this.date,
      read: read ?? this.read,
      starred: starred ?? this.starred,
      isPinned: isPinned ?? this.isPinned,
      labels: labels ?? this.labels,
    );
  }

  @override
  List<Object?> get props => [
        id,
        folderId,
        from,
        fromEmail,
        to,
        cc,
        bcc,
        subject,
        body,
        date,
        read,
        starred,
        isPinned,
        labels,
      ];
}
