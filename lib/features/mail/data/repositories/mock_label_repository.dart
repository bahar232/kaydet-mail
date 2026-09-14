import 'package:uuid/uuid.dart';

import '../../domain/entities/mail_label.dart';
import '../../domain/repositories/label_repository.dart';

class MockLabelRepository implements LabelRepository {
  static const _uuid = Uuid();

  final List<MailLabel> _labels = [
    const MailLabel(id: 'work', name: 'İş', colorId: 'blue'),
    const MailLabel(id: 'personal', name: 'Kişisel', colorId: 'green'),
    const MailLabel(id: 'design', name: 'Tasarım', colorId: 'purple'),
    const MailLabel(id: 'finance', name: 'Finans', colorId: 'yellow'),
  ];

  @override
  Future<List<MailLabel>> fetchLabels() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_labels);
  }

  @override
  Future<MailLabel> createLabel(String name, String colorId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final label = MailLabel(id: _uuid.v4(), name: name, colorId: colorId);
    _labels.add(label);
    return label;
  }
}
