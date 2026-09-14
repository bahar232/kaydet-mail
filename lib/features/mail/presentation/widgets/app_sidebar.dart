import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/entities/mail_folder.dart';
import '../cubit/label_cubit.dart';
import '../cubit/mail_cubit.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentAccount = authState.currentAccount;

    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('KAYDET',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  if (currentAccount != null)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black,
                          child: Text(
                            currentAccount.name.isNotEmpty ? currentAccount.name[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentAccount.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(currentAccount.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (authState.accounts.length > 1 || true) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ...authState.accounts
                        .where((a) => a.id != authState.currentAccountId)
                        .map((acc) => InkWell(
                              onTap: () {
                                context.read<AuthCubit>().switchAccount(acc.id);
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey.shade200,
                                      child: Text(acc.name.isNotEmpty ? acc.name[0].toUpperCase() : 'U',
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(acc.email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const LoginScreen(isAddingAccount: true),
                        ));
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Hesap Ekle',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 4),
                    child: Text('KLASÖRLER',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  BlocBuilder<MailCubit, MailState>(
                    builder: (context, mailState) {
                      return Column(
                        children: MailFolder.defaults.map((folder) {
                          final selected = mailState.currentFolder == folder.id;
                          final count = mailState.folderCount(folder.id);
                          return Material(
                            color: selected ? Colors.black : Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.read<MailCubit>().changeFolder(folder.id);
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(folder.icon, size: 20, color: selected ? Colors.white : Colors.grey.shade700),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(folder.name,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: selected ? Colors.white : Colors.grey.shade800)),
                                    ),
                                    if (count > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: selected ? Colors.white : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('$count',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: selected ? Colors.black : Colors.black)),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 16, 4),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('ETİKETLER',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<LabelCubit, LabelState>(
                    builder: (context, labelState) {
                      return Column(
                        children: labelState.labels
                            .map((tag) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                            color: Colors.black26, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(tag.name, style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
                icon: const Icon(Icons.settings_outlined, size: 18, color: Colors.black),
                label: const Text('Ayarlar',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
