import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../mail/presentation/cubit/label_cubit.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAddLabelDialog(BuildContext context) {
    final controller = TextEditingController();
    var selected = AppColors.labelColorOptions.first;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Yeni Etiket Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Örn: Proje X'),
              ),
              const SizedBox(height: 16),
              const Text('Renk Seç', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.labelColorOptions.map((option) {
                  final isSelected = option.id == selected.id;
                  return GestureDetector(
                    onTap: () => setState(() => selected = option),
                    child: Container(
                      width: 40,
                      height: 32,
                      decoration: BoxDecoration(
                        color: option.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2),
                      ),
                      child: isSelected ? Icon(Icons.check, size: 14, color: option.foreground) : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                context.read<LabelCubit>().createLabel(controller.text.trim(), selected.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Ayarlar'), backgroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            title: 'İçerik',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Etiketler', style: TextStyle(fontWeight: FontWeight.w600))),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddLabelDialog(context)),
                  ],
                ),
                BlocBuilder<LabelCubit, LabelState>(
                  builder: (context, state) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.labels.map((label) {
                      final option = AppColors.labelColorOptions.firstWhere(
                        (o) => o.id == label.colorId,
                        orElse: () => AppColors.labelColorOptions.last,
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: option.background, borderRadius: BorderRadius.circular(6)),
                        child: Text(label.name,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: option.foreground)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Bildirimler ve Senkronizasyon',
            child: BlocBuilder<SettingsCubit, AppSettings>(
              builder: (context, settings) {
                return Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Bildirimlere İzin Ver', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      value: settings.notificationsEnabled,
                      activeThumbColor: Colors.black,
                      onChanged: (v) => context.read<SettingsCubit>().setNotificationsEnabled(v),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Senkronizasyon Sıklığı', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Yeni mailler ne sıklıkla kontrol edilsin?', style: TextStyle(fontSize: 11)),
                      trailing: DropdownButton<String>(
                        value: settings.syncFrequency,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 'push', child: Text('Anlık (Push)')),
                          DropdownMenuItem(value: '15min', child: Text('15 Dakika')),
                          DropdownMenuItem(value: '30min', child: Text('30 Dakika')),
                          DropdownMenuItem(value: '1hour', child: Text('1 Saat')),
                          DropdownMenuItem(value: 'manual', child: Text('Manuel')),
                        ],
                        onChanged: (v) {
                          if (v != null) context.read<SettingsCubit>().setSyncFrequency(v);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.logout, size: 16, color: Colors.red),
            label: const Text('Hesaptan Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
