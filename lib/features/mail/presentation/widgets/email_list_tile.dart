import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/email.dart';
import '../cubit/label_cubit.dart';

class EmailListTile extends StatelessWidget {
  final Email email;
  final bool isSelected;
  final bool showRecipient;
  final VoidCallback onTap;
  final VoidCallback onToggleSelect;

  const EmailListTile({
    super.key,
    required this.email,
    required this.isSelected,
    required this.showRecipient,
    required this.onTap,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.avatarColorFor(email.from);
    final title = showRecipient ? 'Alıcı: ${email.to ?? ''}' : email.from;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          color: isSelected ? Colors.grey.shade50 : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggleSelect,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isSelected ? Colors.black : palette.background,
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        email.from.isNotEmpty ? email.from[0].toUpperCase() : '?',
                        style: TextStyle(color: palette.foreground, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: email.read ? FontWeight.w500 : FontWeight.w900,
                                  color: email.read ? Colors.grey.shade600 : Colors.black,
                                ),
                              ),
                            ),
                            if (email.isPinned) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.push_pin, size: 10, color: Colors.black),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (email.labels.isNotEmpty)
                        BlocBuilder<LabelCubit, LabelState>(
                          builder: (context, labelState) => Wrap(
                            spacing: 4,
                            children: email.labels.map((l) {
                              final match = labelState.labels.where((lbl) => lbl.name == l);
                              final option = match.isNotEmpty
                                  ? AppColors.labelColorOptions.firstWhere(
                                      (c) => c.id == match.first.colorId,
                                      orElse: () => AppColors.labelColorOptions.last,
                                    )
                                  : AppColors.labelColorOptions.last;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: option.background,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(l,
                                    style: TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.bold, color: option.foreground)),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(email.date,
                          style: TextStyle(
                              fontSize: 10,
                              color: email.read ? Colors.grey.shade400 : Colors.black,
                              fontWeight: email.read ? FontWeight.normal : FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(email.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: email.read ? FontWeight.normal : FontWeight.bold,
                          color: email.read ? Colors.grey.shade700 : Colors.black)),
                  const SizedBox(height: 2),
                  Text(email.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
