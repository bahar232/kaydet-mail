import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mail_label.dart';
import '../../domain/repositories/label_repository.dart';

part 'label_state.dart';

class LabelCubit extends Cubit<LabelState> {
  final LabelRepository _repository;

  LabelCubit(this._repository) : super(const LabelState());

  Future<void> loadLabels() async {
    final labels = await _repository.fetchLabels();
    emit(state.copyWith(labels: labels));
  }

  Future<void> createLabel(String name, String colorId) async {
    if (name.trim().isEmpty) return;
    final label = await _repository.createLabel(name.trim(), colorId);
    emit(state.copyWith(labels: [...state.labels, label]));
  }
}
