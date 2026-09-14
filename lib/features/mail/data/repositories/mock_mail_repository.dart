import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../domain/entities/email.dart';
import '../../domain/repositories/mail_repository.dart';

/// In-memory [MailRepository] seeded with sample data, one mailbox per
/// account id. Replace with an implementation that talks to your IMAP/API
/// backend — [MailCubit] only ever depends on the abstract contract.
class MockMailRepository implements MailRepository {
  static const _uuid = Uuid();
  final _random = Random();
  final Map<String, List<Email>> _mailboxes = {};

  List<Email> _mailboxFor(String accountId) {
    return _mailboxes.putIfAbsent(accountId, _seedMailbox);
  }

  @override
  Future<List<Email>> fetchEmails(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_mailboxFor(accountId));
  }

  @override
  Future<List<Email>> loadMore(
    String accountId, {
    required int offset,
    required int count,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final generated = _generateMoreEmails(offset, count);
    _mailboxFor(accountId).addAll(generated);
    return generated;
  }

  @override
  Future<Email> sendEmail(Email draft) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sent = draft.copyWith(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      folderId: 'sent',
      read: true,
      date: 'Şimdi',
    );
    return sent;
  }

  @override
  Future<Email> saveDraft(Email draft) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return draft.copyWith(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      folderId: 'drafts',
      date: 'Şimdi',
    );
  }

  @override
  Future<void> deleteEmail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> updateEmail(Email email) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> bulkUpdate(List<Email> emails) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  List<Email> _seedMailbox() => [
        const Email(
          id: 'init-101',
          folderId: 'inbox',
          from: 'Ahmet Yılmaz',
          fromEmail: 'ahmet@musteri.com',
          subject: 'Fiyat Teklifi Revizesi',
          body:
              'Merhaba,\n\nKonuştuğumuz revizeleri ekte gönderiyorum. Lütfen inceleyip dönüş yapar mısınız?\n\nSaygılar,\nAhmet.',
          date: '10:30',
          read: false,
          starred: true,
          isPinned: true,
          labels: ['İş'],
        ),
        const Email(
          id: 'init-102',
          folderId: 'inbox',
          from: 'Banka Bildirim',
          fromEmail: 'noreply@banka.com',
          subject: 'Hesap Özeti - Şubat 2025',
          body: 'Sayın Müşterimiz,\n\nŞubat ayı hesap özetiniz hazırdır. Detaylar için uygulamaya giriş yapınız.',
          date: 'Dün',
          read: true,
          labels: ['Finans'],
        ),
        const Email(
          id: 'init-103',
          folderId: 'sent',
          from: 'Ben',
          fromEmail: 'me@kaydet.com',
          to: 'mehmet@tedarik.com',
          subject: 'Re: Stok Durumu',
          body: 'Mehmet Bey,\n\nStokları kontrol ettik, sevkiyatı yarın çıkarabiliriz.\n\nİyi çalışmalar.',
          date: 'Pzt',
          read: true,
        ),
        const Email(
          id: 'init-104',
          folderId: 'spam',
          from: 'Kampanya',
          fromEmail: 'info@kampanya.com',
          subject: 'Büyük İndirim Başladı!',
          body: 'Tüm ürünlerde %50 indirim fırsatını kaçırmayın!',
          date: '09:15',
        ),
        const Email(
          id: 'init-105',
          folderId: 'inbox',
          from: 'Zeynep Kaya',
          fromEmail: 'zeynep@tasarim.com',
          subject: 'Logo Çalışmaları',
          body: 'Selamlar,\n\nİstediğiniz siyah beyaz konseptli logo taslakları ektedir.',
          date: '08:00',
          labels: ['Tasarım'],
        ),
        const Email(
          id: 'init-106',
          folderId: 'inbox',
          from: 'Amazon AWS',
          fromEmail: 'no-reply@aws.amazon.com',
          subject: 'AWS Fatura Bildirimi',
          body: 'Sayın Kullanıcı, fatura döneminiz sona erdi. Detaylar ektedir.',
          date: 'Paz',
          read: true,
        ),
        const Email(
          id: 'init-107',
          folderId: 'inbox',
          from: 'Ali Veli',
          fromEmail: 'ali@veli.com',
          subject: 'Toplantı Notları',
          body: 'Arkadaşlar bugünkü toplantı notlarını paylaşıyorum.',
          date: 'Cmt',
          read: true,
          labels: ['İş'],
        ),
        const Email(
          id: 'init-108',
          folderId: 'inbox',
          from: 'Netflix',
          fromEmail: 'info@netflix.com',
          subject: 'Yeni Dizi Önerisi',
          body: 'Sizin için seçtiğimiz yeni dizilere göz atın.',
          date: 'Cuma',
          read: true,
          labels: ['Kişisel'],
        ),
        const Email(
          id: 'init-109',
          folderId: 'inbox',
          from: 'Hepsiburada',
          fromEmail: 'siparis@hepsiburada.com',
          subject: 'Siparişiniz Kargoya Verildi',
          body: 'Siparişiniz yola çıktı. Takip numarası: 123456789',
          date: 'Per',
          read: true,
        ),
        const Email(
          id: 'init-110',
          folderId: 'inbox',
          from: 'Linkedin',
          fromEmail: 'messages@linkedin.com',
          subject: 'Yeni bir mesajınız var',
          body: 'Profilinizi görüntüleyenleri görün.',
          date: 'Çar',
        ),
      ];

  static const _moreSenders = [
    'Trendyol', 'Yemeksepeti', 'Google', 'Apple', 'Spotify', 'Zoom', 'Slack', 'Müşteri A', 'Müşteri B',
  ];
  static const _moreSubjects = [
    'Siparişiniz alındı', 'Güvenlik uyarısı', 'Faturanız hazır', 'Toplantı hatırlatması', 'Yeni giriş yapıldı', 'Haftalık rapor',
  ];

  List<Email> _generateMoreEmails(int startIndex, int count) {
    return List.generate(count, (i) {
      final sender = _moreSenders[_random.nextInt(_moreSenders.length)];
      final subject = _moreSubjects[_random.nextInt(_moreSubjects.length)];
      return Email(
        id: 'more-${_uuid.v4()}',
        folderId: 'inbox',
        from: sender,
        fromEmail: 'info@${sender.toLowerCase()}.com',
        subject: '$subject #${startIndex + i}',
        body:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        date: '${_random.nextInt(28) + 1} Şub',
        read: _random.nextDouble() > 0.3,
        labels: _random.nextDouble() > 0.7 ? const ['İş'] : const [],
      );
    });
  }
}
