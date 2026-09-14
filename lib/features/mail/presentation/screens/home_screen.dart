import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/email.dart';
import '../../domain/entities/mail_folder.dart';
import '../cubit/mail_cubit.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/email_list_tile.dart';
import 'detail_screen.dart';
import '../../../compose/presentation/screens/compose_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MailCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openMail(BuildContext context, Email email) {
    context.read<MailCubit>().markAsRead(email.id);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetailScreen(emailId: email.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      body: SafeArea(
        child: BlocBuilder<MailCubit, MailState>(
          builder: (context, state) {
            final isSelectionMode = state.isSelectionMode;
            final folderName =
                MailFolder.defaults.firstWhere((f) => f.id == state.currentFolder, orElse: () => MailFolder.defaults.first).name;

            return Column(
              children: [
                _buildAppBar(context, state, isSelectionMode, folderName),
                if (state.status == MailStatus.loading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.black)))
                else
                  Expanded(
                    child: Stack(
                      children: [
                        CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            if (state.currentFolder == 'inbox' &&
                                state.pinnedCount > 0 &&
                                !isSelectionMode &&
                                state.searchQuery.isEmpty)
                              SliverToBoxAdapter(child: _buildPinnedBanner(context, state)),
                            if (state.filteredEmails.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(state),
                              )
                            else
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final mail = state.filteredEmails[index];
                                    return EmailListTile(
                                      email: mail,
                                      isSelected: state.selectedIds.contains(mail.id),
                                      showRecipient: state.currentFolder == 'sent',
                                      onTap: () {
                                        if (isSelectionMode) {
                                          context.read<MailCubit>().toggleSelection(mail.id);
                                        } else {
                                          _openMail(context, mail);
                                        }
                                      },
                                      onToggleSelect: () => context.read<MailCubit>().toggleSelection(mail.id),
                                    );
                                  },
                                  childCount: state.filteredEmails.length,
                                ),
                              ),
                            if (state.loadingMore)
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2))),
                                ),
                              ),
                            const SliverToBoxAdapter(child: SizedBox(height: 80)),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<MailCubit, MailState>(
        builder: (context, state) {
          if (state.isSelectionMode) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ComposeScreen()));
            },
            child: const Icon(Icons.edit_outlined),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<MailCubit, MailState>(
        builder: (context, state) {
          if (!state.isSelectionMode) return const SizedBox.shrink();
          return _buildSelectionBar(context);
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MailState state, bool isSelectionMode, String folderName) {
    if (isSelectionMode) {
      return Container(
        height: 56,
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.read<MailCubit>().clearSelection(),
            ),
            Expanded(
              child: Text('${state.selectedIds.length} seçildi',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            TextButton(
              onPressed: () => context.read<MailCubit>().selectAll(),
              child: Text(
                state.selectedIds.length == state.filteredEmails.length ? 'Vazgeç' : 'Tümünü Seç',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearchOpen) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() => _isSearchOpen = false);
                _searchController.clear();
                context.read<MailCubit>().setSearchQuery('');
              },
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Mail ara...',
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
                onChanged: (v) => context.read<MailCubit>().setSearchQuery(v),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Expanded(child: Text(folderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _isSearchOpen = true),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedBanner(BuildContext context, MailState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: InkWell(
        onTap: () => context.read<MailCubit>().changeFolder('pinned'),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                child: Icon(Icons.push_pin, size: 14, color: Colors.orange.shade700),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Sabitlenenler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                child: Text('${state.pinnedCount}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(MailState state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(state.searchQuery.isNotEmpty ? Icons.search_off : Icons.inbox_outlined,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(state.searchQuery.isNotEmpty ? 'Sonuç bulunamadı.' : 'Klasör boş.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _selectionAction(context, Icons.delete_outline, 'Sil', () => context.read<MailCubit>().bulkAction('delete')),
            _selectionAction(context, Icons.mail_outline, 'Okundu', () => context.read<MailCubit>().bulkAction('read')),
            _selectionAction(context, Icons.push_pin_outlined, 'Sabitle', () => context.read<MailCubit>().bulkAction('pin')),
            _selectionAction(context, Icons.archive_outlined, 'Arşiv', () => context.read<MailCubit>().bulkAction('archive')),
          ],
        ),
      ),
    );
  }

  Widget _selectionAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
