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
    final filteredConversationsAsync = ref.watch(filteredConversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 19),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SearchTextInputField(
              controller: searchController,
              hintText: 'Search Name...',
            ),
          ),
          12.0.height,
          if (filteredConversationsAsync.isLoading) ...[
            const LineLoadingIndicator(loading: true),
            12.0.height,
          ],

          // MARK: Chat List
          Expanded(
            child: RefreshIndicator.adaptive(
              backgroundColor: AppColors.grey50,
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(fetchConversationsProvider);
              },
              child: filteredConversationsAsync.when(
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: EmptyChatsWidget(),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: conversations.length + 1,
                    separatorBuilder: (context, index) {
                      if (index == conversations.length - 1) {
                        return const SizedBox.shrink();
                      }
                      return 1.0.height;
                    },
                    itemBuilder: (context, index) {
                      if (index == conversations.length) {
                        return const _ChatFooterWidget();
                      }
                      final conversation = conversations[index];
                      return ChatCard(conversation: conversation);
                    },
                  );
                },
                loading: () => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                      8.0.height,
                      const Text('Loading Conversations...'),
                    ],
                  ),
                ),
                error: (error, stack) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ChatErrorWidget(
                      onRetry: () {
                        ref.invalidate(fetchConversationsProvider);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
