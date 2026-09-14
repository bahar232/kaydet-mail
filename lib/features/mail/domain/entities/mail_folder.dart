import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A well-known mail folder. Ids are fixed system identifiers; only the
/// unread [count] changes at runtime and is computed from loaded emails.
class MailFolder extends Equatable {
  final String id;
  final String name;
  final IconData icon;

  const MailFolder({required this.id, required this.name, required this.icon});

  static const List<MailFolder> defaults = [
    MailFolder(id: 'inbox', name: 'Gelen Kutusu', icon: Icons.inbox_outlined),
    MailFolder(id: 'sent', name: 'Gönderilenler', icon: Icons.send_outlined),
    MailFolder(id: 'pinned', name: 'Sabitlenenler', icon: Icons.push_pin_outlined),
    MailFolder(id: 'drafts', name: 'Taslaklar', icon: Icons.description_outlined),
    MailFolder(id: 'trash', name: 'Çöp Kutusu', icon: Icons.delete_outline),
    MailFolder(id: 'spam', name: 'Spam', icon: Icons.report_gmailerrorred_outlined),
  ];

  @override
  List<Object?> get props => [id, name];
}
