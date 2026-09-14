part of 'mail_cubit.dart';

enum MailStatus { initial, loading, loaded, error }

class MailState extends Equatable {
  final MailStatus status;
  final String? accountId;
  final List<Email> emails;
  final String currentFolder;
  final String searchQuery;
  final Set<String> selectedIds;
  final bool loadingMore;
  final String? errorMessage;

  const MailState({
    this.status = MailStatus.initial,
    this.accountId,
    this.emails = const [],
    this.currentFolder = 'inbox',
    this.searchQuery = '',
    this.selectedIds = const {},
    this.loadingMore = false,
    this.errorMessage,
  });

  bool get isSelectionMode => selectedIds.isNotEmpty;

  List<Email> get filteredEmails {
    final query = searchQuery.trim().toLowerCase();
    return emails.where((e) {
      final matchesFolder = currentFolder == 'pinned' ? e.isPinned : e.folderId == currentFolder;
      if (!matchesFolder) return false;
      if (query.isEmpty) return true;
      return e.subject.toLowerCase().contains(query) ||
          e.from.toLowerCase().contains(query) ||
          e.body.toLowerCase().contains(query);
    }).toList();
  }

  int get pinnedCount => emails.where((e) => e.isPinned).length;

  int folderCount(String folderId) {
    if (folderId == 'pinned') return pinnedCount;
    if (folderId == 'drafts') return emails.where((e) => e.folderId == 'drafts').length;
    return emails.where((e) => e.folderId == folderId && !e.read).length;
  }

  MailState copyWith({
    MailStatus? status,
    String? accountId,
    List<Email>? emails,
    String? currentFolder,
    String? searchQuery,
    Set<String>? selectedIds,
    bool? loadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MailState(
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      emails: emails ?? this.emails,
      currentFolder: currentFolder ?? this.currentFolder,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIds: selectedIds ?? this.selectedIds,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        accountId,
        emails,
        currentFolder,
        searchQuery,
        selectedIds,
        loadingMore,
        errorMessage,
      ];
}
