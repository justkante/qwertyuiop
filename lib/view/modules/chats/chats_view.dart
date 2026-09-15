import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_vm.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/chat_card.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/empty_chats_widget.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/linear_loading.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final chatFilterProvider = StateProvider<String>((ref) => 'All');

class ChatsView extends ConsumerStatefulWidget {
  const ChatsView({super.key});

  @override
  ConsumerState<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends ConsumerState<ChatsView> {
  final searchController = TextEditingController();

  void _onSearchChanged() {
    ref.read(searchNotifier.notifier).updateSearch(searchController.text);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);

    // Initialize Pusher connection when the chat view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pusherInitializationProvider);
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final filteredConversationsAsync = ref.watch(filteredConversationsProvider);
    final selectedFilter = ref.watch(chatFilterProvider);
    final totalUnreadCount = ref.watch(totalUnreadCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chats',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.body, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Filter Tabs
          12.0.height,
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildFilterChip('All'),
                12.0.width,
                _buildFilterChip('Unread', badgeCount: totalUnreadCount),
                12.0.width,
                _buildFilterChip('Bookings'),
                12.0.width,
                _buildFilterChip('Support'),
              ],
            ),
          ),
          16.0.height,

          if (filteredConversationsAsync.isLoading) ...[
            const LineLoadingIndicator(loading: true),
            12.0.height,
          ],

          // MARK: Chat List
          Expanded(
            child: RefreshIndicator.adaptive(
              backgroundColor: Colors.white,
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(fetchConversationsProvider);
              },
              child: filteredConversationsAsync.when(
                data: (conversations) {
                  // Apply UI filters based on selected tab
                  var displayConversations = conversations;
                  if (selectedFilter == 'Unread') {
                    displayConversations = conversations.where((c) => (c.unreadCount ?? 0) > 0).toList();
                  } else if (selectedFilter == 'Bookings') {
                    // Logic to identify booking-related chats if available in DTO
                    displayConversations = conversations.where((c) => c.bookingId != null).toList();
                  } else if (selectedFilter == 'Support') {
                    displayConversations = conversations.where((c) => c.otherUser?.name?.toLowerCase().contains('support') ?? false).toList();
                  }

                  if (displayConversations.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: EmptyChatsWidget(filter: selectedFilter),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: displayConversations.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.grey100, height: 1),
                    itemBuilder: (context, index) {
                      return ChatCard(conversation: displayConversations[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, stack) => _ChatErrorWidget(
                  onRetry: () => ref.invalidate(fetchConversationsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {int badgeCount = 0}) {
    final selectedFilter = ref.watch(chatFilterProvider);
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () => ref.read(chatFilterProvider.notifier).state = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B3131) : AppColors.grey50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF1B3131) : AppColors.grey100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.body,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            if (badgeCount > 0) ...[
              6.0.width,
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Reusable widget for chat footer message
class _ChatFooterWidget extends StatelessWidget {
  const _ChatFooterWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "Your chats are monitored ",
          style: context.textTheme.bodySmall,
          children: [
            TextSpan(
              text: 'end to end',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for error state
class _ChatErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _ChatErrorWidget({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.highlightRed,
          ),
          16.0.height,
          Text(
            'Failed to load chats',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.subHeading,
            ),
          ),
          8.0.height,
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
