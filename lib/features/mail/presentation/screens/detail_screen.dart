import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../compose/presentation/screens/compose_screen.dart';
import '../cubit/mail_cubit.dart';

class DetailScreen extends StatelessWidget {
  final String emailId;

  const DetailScreen({super.key, required this.emailId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MailCubit, MailState>(
      builder: (context, state) {
        final list = state.filteredEmails;
        final index = list.indexWhere((e) => e.id == emailId);
        if (index == -1) {
          // The mail left the current filtered list (e.g. deleted); go back.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final email = list[index];
        final hasPrev = index > 0;
        final hasNext = index < list.length - 1;
        final palette = AppColors.avatarColorFor(email.from);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _navButton(context, Icons.keyboard_arrow_up, hasPrev, () => _navigate(context, list, index - 1)),
                _navButton(context, Icons.keyboard_arrow_down, hasNext, () => _navigate(context, list, index + 1)),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenu(context, value, email.id),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'pin', child: Text(email.isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle')),
                  const PopupMenuItem(value: 'label', child: Text('Etiketle: "İş"')),
                  const PopupMenuItem(value: 'spam', child: Text('Spam Bildir')),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(email.subject,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                    ),
                    if (email.isPinned) const Padding(
                      padding: EdgeInsets.only(left: 8, top: 4),
                      child: Icon(Icons.push_pin, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: palette.background,
                      child: Text(email.from.isNotEmpty ? email.from[0] : '?',
                          style: TextStyle(color: palette.foreground, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email.from, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(email.fromEmail, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                    Text(email.date, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  ],
                ),
                const Divider(height: 24),
                Text(email.body, style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 56,
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  _bottomAction(context, Icons.reply_outlined, 'Yanıtla', () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ComposeScreen(
                        initialTo: email.fromEmail,
                        initialSubject: 'Re: ${email.subject}',
                      ),
                    ));
                  }),
                  _bottomAction(context, Icons.forward_outlined, 'İlet', () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ComposeScreen(
                        initialSubject: 'Fwd: ${email.subject}',
                        initialBody: '\n\n--- İletilen ---\n${email.body}',
                      ),
                    ));
                  }),
                  _bottomAction(context, Icons.archive_outlined, 'Arşiv', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arşivlendi')));
                  }),
                  _bottomAction(context, Icons.delete_outline, 'Sil', () {
                    context.read<MailCubit>().deleteMail(email.id);
                    Navigator.of(context).pop();
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigate(BuildContext context, List list, int newIndex) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => DetailScreen(emailId: list[newIndex].id),
    ));
  }

  void _handleMenu(BuildContext context, String action, String emailId) {
    final cubit = context.read<MailCubit>();
    switch (action) {
      case 'pin':
        cubit.togglePin(emailId);
        break;
      case 'label':
        cubit.addLabel(emailId, 'İş');
        break;
      case 'spam':
        cubit.deleteMail(emailId);
        Navigator.of(context).pop();
        break;
    }
  }

  Widget _navButton(BuildContext context, IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18, color: enabled ? Colors.black : Colors.grey.shade300),
      onPressed: enabled ? onTap : null,
    );
  }

  Widget _bottomAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
