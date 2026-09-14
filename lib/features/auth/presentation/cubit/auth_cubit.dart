import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mail_account.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

/// Owns the account list and which one is active. [MailCubit] and other
/// feature cubits read the current account id from here; they never talk
/// to [AuthRepository] directly.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  Future<void> checkSavedSession() async {
    emit(state.copyWith(isBusy: true));
    final accounts = await _repository.loadSavedAccounts();
    if (accounts.isEmpty) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, isBusy: false, accounts: accounts));
    } else {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isBusy: false,
        accounts: accounts,
        currentAccountId: accounts.first.id,
      ));
    }
  }

  Future<void> login(LoginCredentials credentials) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final account = await _repository.login(credentials);
      final updated = [...state.accounts, account];
      await _repository.persistAccounts(updated);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isBusy: false,
        accounts: updated,
        currentAccountId: account.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        isBusy: false,
        errorMessage: 'Giriş başarısız oldu. Bilgilerinizi kontrol edin.',
      ));
    }
  }

  void switchAccount(String accountId) {
    emit(state.copyWith(currentAccountId: accountId));
  }

  Future<void> logout() async {
    final currentId = state.currentAccountId;
    final remaining = state.accounts.where((a) => a.id != currentId).toList();
    await _repository.persistAccounts(remaining);

    if (remaining.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        accounts: remaining,
        clearCurrentAccountId: true,
      ));
    } else {
      emit(state.copyWith(accounts: remaining, currentAccountId: remaining.first.id));
    }
  }
}
