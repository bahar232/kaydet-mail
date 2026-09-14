import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/email.dart';
import '../../domain/repositories/mail_repository.dart';

part 'mail_state.dart';

/// Owns the mailbox for whichever account is currently active.
///
/// [loadForAccount] should be called whenever [AuthCubit]'s current
/// account changes (see `HomeScreen`'s `BlocListener`); this cubit itself
/// has no dependency on auth state.
class MailCubit extends Cubit<MailState> {
  final MailRepository _repository;

  MailCubit(this._repository) : super(const MailState());

  Future<void> loadForAccount(String accountId) async {
    emit(MailState(status: MailStatus.loading, accountId: accountId));
    try {
      final emails = await _repository.fetchEmails(accountId);
      emit(state.copyWith(status: MailStatus.loaded, emails: emails));
    } catch (_) {
      emit(state.copyWith(status: MailStatus.error, errorMessage: 'E-postalar yüklenemedi.'));
    }
  }

  void changeFolder(String folderId) {
    emit(state.copyWith(currentFolder: folderId, selectedIds: {}));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.accountId == null) return;
    if (state.currentFolder != 'inbox' || state.searchQuery.isNotEmpty) return;

    emit(state.copyWith(loadingMore: true));
    final more = await _repository.loadMore(
      state.accountId!,
      offset: state.emails.length,
      count: 15,
    );
    emit(state.copyWith(emails: [...state.emails, ...more], loadingMore: false));
  }

  void toggleSelection(String emailId) {
    final updated = {...state.selectedIds};
    if (!updated.remove(emailId)) updated.add(emailId);
    emit(state.copyWith(selectedIds: updated));
  }

  void selectAll() {
    final visibleIds = state.filteredEmails.map((e) => e.id).toSet();
    final allSelected = state.selectedIds.length == visibleIds.length;
    emit(state.copyWith(selectedIds: allSelected ? {} : visibleIds));
  }

  void clearSelection() => emit(state.copyWith(selectedIds: {}));

  Future<void> bulkAction(String action) async {
    final ids = state.selectedIds;
    if (ids.isEmpty) return;

    List<Email> updated = state.emails;
    switch (action) {
      case 'delete':
        updated = state.emails.where((e) => !ids.contains(e.id)).toList();
        break;
      case 'read':
        updated = _mapWhereSelected(ids, (e) => e.copyWith(read: true));
        break;
      case 'pin':
        updated = _mapWhereSelected(ids, (e) => e.copyWith(isPinned: true));
        break;
      case 'archive':
        updated = state.emails.where((e) => !ids.contains(e.id)).toList();
        break;
    }
    emit(state.copyWith(emails: updated, selectedIds: {}));
  }

  List<Email> _mapWhereSelected(Set<String> ids, Email Function(Email) transform) {
    return state.emails.map((e) => ids.contains(e.id) ? transform(e) : e).toList();
  }

  Future<void> markAsRead(String emailId) async {
    final email = state.emails.firstWhere((e) => e.id == emailId);
    if (email.read) return;
    final updated = email.copyWith(read: true);
    emit(state.copyWith(emails: _replace(updated)));
    await _repository.updateEmail(updated);
  }

  Future<void> togglePin(String emailId) async {
    final email = state.emails.firstWhere((e) => e.id == emailId);
    final updated = email.copyWith(isPinned: !email.isPinned);
    emit(state.copyWith(emails: _replace(updated)));
    await _repository.updateEmail(updated);
  }

  Future<void> addLabel(String emailId, String label) async {
    final email = state.emails.firstWhere((e) => e.id == emailId);
    if (email.labels.contains(label)) return;
    final updated = email.copyWith(labels: [...email.labels, label]);
    emit(state.copyWith(emails: _replace(updated)));
    await _repository.updateEmail(updated);
  }

  Future<void> deleteMail(String emailId) async {
    final email = state.emails.firstWhere((e) => e.id == emailId);
    if (email.folderId == 'trash') {
      emit(state.copyWith(emails: state.emails.where((e) => e.id != emailId).toList()));
      await _repository.deleteEmail(emailId);
    } else {
      final updated = email.copyWith(folderId: 'trash');
      emit(state.copyWith(emails: _replace(updated)));
      await _repository.updateEmail(updated);
    }
  }

  /// Merges a just-sent or just-saved draft (see `ComposeCubit`) into the
  /// mailbox, replacing any earlier draft with the same id.
  void upsertEmail(Email email) {
    final exists = state.emails.any((e) => e.id == email.id);
    final updated = exists ? _replace(email) : [...state.emails, email];
    emit(state.copyWith(emails: updated));
  }

  List<Email> _replace(Email updated) {
    return state.emails.map((e) => e.id == updated.id ? updated : e).toList();
  }
}
