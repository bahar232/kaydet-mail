import 'package:equatable/equatable.dart';

/// A user-defined label (tag) that can be attached to emails.
class MailLabel extends Equatable {
  final String id;
  final String name;
  final String colorId;

  const MailLabel({required this.id, required this.name, required this.colorId});

  @override
  List<Object?> get props => [id, name, colorId];
}
