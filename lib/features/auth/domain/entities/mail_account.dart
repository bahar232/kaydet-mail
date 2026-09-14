import 'package:equatable/equatable.dart';

/// A configured mail account (one IMAP/SMTP identity).
class MailAccount extends Equatable {
  final String id;
  final String email;
  final String name;
  final String signature;
  final String imapServer;
  final String imapPort;
  final String smtpServer;
  final String smtpPort;
  final String securityType;

  const MailAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.signature,
    required this.imapServer,
    required this.imapPort,
    required this.smtpServer,
    required this.smtpPort,
    required this.securityType,
  });

  @override
  List<Object?> get props => [id, email, name, signature];
}

/// Raw credentials collected from the login form, before an account is
/// created. Kept separate from [MailAccount] since it also carries the
/// password, which the account entity never stores in memory long-term.
///
/// Only email + password are user-provided (Outlook/Gmail-style login);
/// [AuthRepository] is responsible for resolving IMAP/SMTP server details
/// behind the scenes (autodiscovery against the real backend, later).
class LoginCredentials extends Equatable {
  final String email;
  final String password;

  const LoginCredentials({required this.email, required this.password});

  @override
  List<Object?> get props => [email];
}
