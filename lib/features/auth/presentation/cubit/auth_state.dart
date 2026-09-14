part of 'auth_cubit.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final bool isBusy;
  final List<MailAccount> accounts;
  final String? currentAccountId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.isBusy = false,
    this.accounts = const [],
    this.currentAccountId,
    this.errorMessage,
  });

  MailAccount? get currentAccount {
    if (currentAccountId == null) return null;
    for (final account in accounts) {
      if (account.id == currentAccountId) return account;
    }
    return null;
  }

  AuthState copyWith({
    AuthStatus? status,
    bool? isBusy,
    List<MailAccount>? accounts,
    String? currentAccountId,
    bool clearCurrentAccountId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isBusy: isBusy ?? this.isBusy,
      accounts: accounts ?? this.accounts,
      currentAccountId:
          clearCurrentAccountId ? null : (currentAccountId ?? this.currentAccountId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, isBusy, accounts, currentAccountId, errorMessage];
}
