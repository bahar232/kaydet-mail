import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/mail_account.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory + local-storage backed [AuthRepository].
///
/// Stands in for a real backend call. Replace this class (only this
/// class) with one that calls your login API once it exists — the
/// [AuthRepository] contract and everything using it stays the same.
class MockAuthRepository implements AuthRepository {
  static const _storageKey = 'kaydet_accounts';
  static const _uuid = Uuid();

  @override
  Future<List<MailAccount>> loadSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<MailAccount> login(LoginCredentials credentials) async {
    // Simulates network latency of a real IMAP/SMTP autodiscovery + handshake.
    await Future.delayed(const Duration(milliseconds: 800));

    final localPart = credentials.email.split('@').first;
    final domain = credentials.email.split('@').last;
    return MailAccount(
      id: _uuid.v4(),
      email: credentials.email,
      name: localPart,
      signature: '\n\n--\n$localPart\nSent from KAYDET Mail',
      // Autodiscovered from the email domain — the user never enters these.
      // A real backend would resolve these via an autoconfig lookup instead.
      imapServer: 'mail.$domain',
      imapPort: '993',
      smtpServer: 'mail.$domain',
      smtpPort: '465',
      securityType: 'SSL',
    );
  }

  @override
  Future<void> persistAccounts(List<MailAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    if (accounts.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }
    final raw = jsonEncode(accounts.map(_toJson).toList());
    await prefs.setString(_storageKey, raw);
  }

  Map<String, dynamic> _toJson(MailAccount a) => {
        'id': a.id,
        'email': a.email,
        'name': a.name,
        'signature': a.signature,
        'imapServer': a.imapServer,
        'imapPort': a.imapPort,
        'smtpServer': a.smtpServer,
        'smtpPort': a.smtpPort,
        'securityType': a.securityType,
      };

  MailAccount _fromJson(Map<String, dynamic> json) => MailAccount(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        signature: json['signature'] as String? ?? '',
        imapServer: json['imapServer'] as String? ?? '',
        imapPort: json['imapPort'] as String? ?? '',
        smtpServer: json['smtpServer'] as String? ?? '',
        smtpPort: json['smtpPort'] as String? ?? '',
        securityType: json['securityType'] as String? ?? 'NONE',
      );
}
