import '../entities/mail_label.dart';

abstract class LabelRepository {
  Future<List<MailLabel>> fetchLabels();

  Future<MailLabel> createLabel(String name, String colorId);
}
