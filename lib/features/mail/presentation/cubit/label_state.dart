part of 'label_cubit.dart';

class LabelState extends Equatable {
  final List<MailLabel> labels;

  const LabelState({this.labels = const []});

  LabelState copyWith({List<MailLabel>? labels}) {
    return LabelState(labels: labels ?? this.labels);
  }

  @override
  List<Object?> get props => [labels];
}
