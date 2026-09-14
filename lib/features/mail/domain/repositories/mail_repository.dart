import '../entities/email.dart';

/// Contract for reading and mutating mail data for one account.
///
/// Every method is `Future`-based so a real, network-backed
/// implementation drops in without touching [MailCubit] or any screen.
abstract class MailRepository {
  Future<List<Email>> fetchEmails(String accountId);

  Future<List<Email>> loadMore(String accountId, {required int offset, required int count});

  Future<Email> sendEmail(Email draft);

  Future<Email> saveDraft(Email draft);

  Future<void> deleteEmail(String id);

  Future<void> updateEmail(Email email);

  Future<void> bulkUpdate(List<Email> emails);
}
