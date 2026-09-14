import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../mail/domain/repositories/mail_repository.dart';
import '../../../mail/presentation/cubit/mail_cubit.dart';
import '../cubit/compose_cubit.dart';

class ComposeScreen extends StatelessWidget {
  final String initialTo;
  final String initialSubject;
  final String initialBody;

  const ComposeScreen({
    super.key,
    this.initialTo = '',
    this.initialSubject = '',
    this.initialBody = '',
  });

  @override
  Widget build(BuildContext context) {
    final account = context.read<AuthCubit>().state.currentAccount;
    final signature = account?.signature ?? '';

    return BlocProvider(
      create: (context) => ComposeCubit(
        context.read<MailRepository>(),
        fromName: account?.name ?? '',
        fromEmail: account?.email ?? '',
        initial: ComposeState(
          to: initialTo,
          subject: initialSubject,
          body: initialBody.isNotEmpty ? initialBody : signature,
        ),
      ),
      child: const _ComposeView(),
    );
  }
}

class _ComposeView extends StatefulWidget {
  const _ComposeView();

  @override
  State<_ComposeView> createState() => _ComposeViewState();
}

class _ComposeViewState extends State<_ComposeView> {
  late final TextEditingController _to;
  late final TextEditingController _cc;
  late final TextEditingController _bcc;
  late final TextEditingController _subject;
  late final TextEditingController _body;
  bool _showCcBcc = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ComposeCubit>().state;
    _to = TextEditingController(text: state.to);
    _cc = TextEditingController(text: state.cc);
    _bcc = TextEditingController(text: state.bcc);
    _subject = TextEditingController(text: state.subject);
    _body = TextEditingController(text: state.body);
  }

  @override
  void dispose() {
    _to.dispose();
    _cc.dispose();
    _bcc.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final cubit = context.read<ComposeCubit>();
    if (!cubit.hasContent) return true;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taslak Kaydedilsin mi?'),
        content: const Text('İletiniz gönderilmedi. Taslaklara kaydetmek ister misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'cancel'), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Navigator.pop(context, 'draft'), child: const Text('Taslağı Kaydet')),
        ],
      ),
    );

    if (choice == 'draft') {
      await cubit.saveDraft();
      if (context.mounted && cubit.state.result != null) {
        context.read<MailCubit>().upsertEmail(cubit.state.result!);
      }
      return true;
    }
    return choice == 'delete';
  }

  Future<void> _send() async {
    final cubit = context.read<ComposeCubit>()
      ..updateTo(_to.text)
      ..updateCc(_cc.text)
      ..updateBcc(_bcc.text)
      ..updateSubject(_subject.text)
      ..updateBody(_body.text);
    await cubit.send();
    if (!mounted) return;
    if (cubit.state.result != null) {
      context.read<MailCubit>().upsertEmail(cubit.state.result!);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmExit() && mounted) Navigator.of(context).pop();
            },
          ),
          title: const Text('Yeni İleti'),
          actions: [
            BlocBuilder<ComposeCubit, ComposeState>(
              builder: (context, state) => IconButton(
                icon: state.status == ComposeStatus.sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                onPressed: state.status == ComposeStatus.sending ? null : _send,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _row('Kime:', _to, trailing: IconButton(
              icon: Icon(_showCcBcc ? Icons.expand_less : Icons.expand_more, size: 18),
              onPressed: () => setState(() => _showCcBcc = !_showCcBcc),
            )),
            if (_showCcBcc) ...[
              _row('Bilgi:', _cc),
              _row('Gizli:', _bcc),
            ],
            _row('Konu:', _subject, bold: true),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _body,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'İletinizi buraya yazın...',
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  Icon(Icons.attach_file, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text('Dosya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  const SizedBox(width: 20),
                  Icon(Icons.mic_none, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text('Sesli Yaz', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, TextEditingController controller, {bool bold = false, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.w500),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, filled: false),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
