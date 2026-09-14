import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../mail/domain/entities/email.dart';
import '../../../mail/domain/repositories/mail_repository.dart';

part 'compose_state.dart';

/// Short-lived cubit for a single compose/reply/forward session. Create a
/// fresh instance per `ComposeScreen` route rather than sharing one globally.
class ComposeCubit extends Cubit<ComposeState> {
  final MailRepository _repository;
  final String _fromName;
  final String _fromEmail;

  ComposeCubit(
    this._repository, {
    required String fromName,
    required String fromEmail,
    ComposeState? initial,
  })  : _fromName = fromName,
        _fromEmail = fromEmail,
        super(initial ?? const ComposeState());

  void updateTo(String value) => emit(state.copyWith(to: value));
  void updateCc(String value) => emit(state.copyWith(cc: value));
  void updateBcc(String value) => emit(state.copyWith(bcc: value));
  void updateSubject(String value) => emit(state.copyWith(subject: value));
  void updateBody(String value) => emit(state.copyWith(body: value));

  bool get hasContent =>
      state.to.trim().isNotEmpty || state.subject.trim().isNotEmpty || state.body.trim().isNotEmpty;

  Email _draftFromState() => Email(
        id: state.id,
        folderId: 'drafts',
        from: _fromName,
        fromEmail: _fromEmail,
        to: state.to,
        cc: state.cc,
        bcc: state.bcc,
        subject: state.subject,
        body: state.body,
        date: '',
      );

  Future<void> send() async {
    emit(state.copyWith(status: ComposeStatus.sending));
    final sent = await _repository.sendEmail(_draftFromState());
    emit(state.copyWith(status: ComposeStatus.sent, result: sent));
  }

  Future<void> saveDraft() async {
    emit(state.copyWith(status: ComposeStatus.sending));
    final draft = await _repository.saveDraft(_draftFromState());
    emit(state.copyWith(status: ComposeStatus.draftSaved, result: draft));
  }
}
