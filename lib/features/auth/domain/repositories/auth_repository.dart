import '../entities/mail_account.dart';

/// Contract for account/session persistence.
///
/// Swap [MockAuthRepository] for a real implementation (talking to your
/// backend or directly to an IMAP/SMTP client) once the API is ready —
/// nothing above this layer needs to change.
abstract class AuthRepository {
  Future<List<MailAccount>> loadSavedAccounts();

  Future<MailAccount> login(LoginCredentials credentials);

  Future<void> persistAccounts(List<MailAccount> accounts);
}
