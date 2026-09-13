import 'dart:developer';

import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/booking_complete.dart';
import 'package:creatify_mobile/view/modules/bookings/booking_details_view.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/mark_completed_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/mark_deliverable_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/report_account_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/report_booking_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/update_status_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/update_creator_deliverable_view.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/mark_completed_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/update_booking_status_vm.dart';
import 'package:creatify_mobile/view/modules/chats/sheets/chat_attachments_sheet.dart';
import 'package:creatify_mobile/view/modules/chats/sheets/request_extension_sheet.dart';
import 'package:creatify_mobile/view/modules/chats/sheets/view_extension_sheet.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/modules/chats/vm/conversation_vm.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/chat_bar_title.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/chat_date_header.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/chat_input_field.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/chat_popup.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/empty_message_widget.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/error_widget.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/message_bubble.dart';
import 'package:creatify_mobile/view/modules/chats/widgets/typing_indicator.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/widgets/overlay_animation.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';

class ChatConversationView extends ConsumerStatefulWidget {
  final ConversationDto conversation;

  const ChatConversationView({
    super.key,
    required this.conversation,
  });

  @override
  ConsumerState<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends ConsumerState<ChatConversationView>
    with WidgetsBindingObserver {
  final GlobalKey _menuButtonKey = GlobalKey();
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  bool _showScrollToBottomButton = false;
  bool _hasScrolledToBottom = false;
  bool _tourStarted = false;
  late final ShowcaseView _showcaseView;

  // Get current user ID from SharedPreferences
  String get currentUserId => SharedPrefManager.userId;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      scope: 'chat-conversation',
      onFinish: () => TourService.markScreenDone(TourService.chatConversation),
    );
    _tourStarted = !TourService.shouldShowScreenTour(TourService.chatConversation);
    WidgetsBinding.instance.addObserver(this);

    // Add scroll listener to show/hide the scroll-to-bottom button
    scrollController.addListener(_onScroll);

    // Initialize Pusher connection when opening conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize Pusher if not already done
      ref.read(pusherInitializationProvider);

      // Send user presence (online) when entering conversation
      _updatePresence(true);

      // Mark messages as read when entering conversation
      _markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    messageController.dispose();
    scrollController.dispose();
    _hasScrolledToBottom = false;
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Update presence and connection based on app lifecycle
    switch (state) {
      case AppLifecycleState.resumed:
        log('Chat conversation view: App resumed');
        // Ensure Pusher connection is alive
        _ensurePusherConnected();
        _updatePresence(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        log('Chat conversation view: App backgrounded');
        _updatePresence(false);
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Ensure Pusher is connected and reconnect if necessary
  void _ensurePusherConnected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Access the underlying PusherService through ChatPusherService
        final chatPusherService = ref.read(chatPusherServiceProvider);
        final pusherService = chatPusherService.pusherService;

        if (!pusherService.isConnected) {
          log('Pusher disconnected after resume, attempting reconnection...');
          pusherService.reconnect();
        }
      } catch (e) {
        log('Error ensuring Pusher connection: $e');
      }
    });
  }

  void _sendMessage() {
    final message = messageController.text.trim();
    if (message.isEmpty || widget.conversation.id == null) return;

    // Create a temporary pending message
    final pendingMessage = ConversationMessageDto(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversation.id!,
      senderId: currentUserId,
      senderName: 'You',
      message: message,
      createdAt: DateTime.now(),
      type: 'pending', // Mark as pending
    );

    // Add pending message to the list
    final currentPending = ref.read(pendingMessagesProvider(widget.conversation.id!));
    ref.read(pendingMessagesProvider(widget.conversation.id!).notifier).state = [
      ...currentPending,
      pendingMessage,
    ];

    messageController.clear();
    _scrollToBottom();

    // Send the actual message
    ref.read(sendMessageNotifier.notifier).sendMessage(
          conversationId: widget.conversation.id!,
          message: message,
        );
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    // Show button if 100 pixels away from bottom
    const threshold = 80.0;

    final shouldShow = (maxScroll - currentScroll) > threshold;

    if (shouldShow != _showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = shouldShow;
      });
    }
  }

  void _onAttachment() {
    AppBottomSheet.showBottomSheet(
      context,
      widget: ChatAttachmentSheet(
        isCreator: widget.conversation.isCreator == true,
        bookingId: widget.conversation.bookingId,
        conversationId: widget.conversation.id,
      ),
    );
  }

  void _onTyping(String text) {
    if (widget.conversation.id != null) {
      _scrollToBottom();
      if (text.isNotEmpty) {
        ref.read(typingIndicatorNotifier.notifier).startTyping(widget.conversation.id!);
      } else {
        ref.read(typingIndicatorNotifier.notifier).stopTyping(widget.conversation.id!);
      }
    }
  }

  void _markMessagesAsRead() {
    if (widget.conversation.id == null) return;

    // Get the current state of messages
    final messagesAsync = ref.read(fetchMessagesProvider(widget.conversation.id!));

    // Check if messages are already loaded
    messagesAsync.whenOrNull(
      data: (messages) {
        log('Fetched messages for conversationId: ${widget.conversation.id!}');
        if (messages.isNotEmpty) {
          log('Found ${messages.length} messages to mark as read');
          final lastMessage = messages.last;
          if (lastMessage.id != null) {
            log('Marking message as read: ${lastMessage.id!}');
            ref.read(markMessagesReadNotifier.notifier).markMessagesAsRead(
                  conversationId: widget.conversation.id!,
                  lastReadMessageId: lastMessage.id!,
                );
          }
        } else {
          log('No messages to mark as read');
        }
      },
      loading: () {
        log('Messages still loading, will mark as read once loaded');
        // Wait for messages to load and retry marking as read
        _retryMarkingAsRead(retryCount: 0, maxRetries: 10);
      },
      error: (error, stack) {
        log('Error loading messages: $error');
      },
    );
  }

  void _retryMarkingAsRead({required int retryCount, required int maxRetries}) {
    if (retryCount >= maxRetries) {
      log('Max retries reached for marking messages as read');
      return;
    }

    Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)), () {
      if (!mounted || widget.conversation.id == null) return;

      final messagesAsync = ref.read(fetchMessagesProvider(widget.conversation.id!));
      messagesAsync.whenOrNull(
        data: (messages) {
          if (messages.isNotEmpty) {
            final lastMessage = messages.last;
            if (lastMessage.id != null) {
              log('Messages loaded on retry $retryCount, now marking as read: ${lastMessage.id!}');
              ref.read(markMessagesReadNotifier.notifier).markMessagesAsRead(
                    conversationId: widget.conversation.id!,
                    lastReadMessageId: lastMessage.id!,
                  );
            }
          }
        },
        loading: () {
          // Still loading, retry again
          _retryMarkingAsRead(retryCount: retryCount + 1, maxRetries: maxRetries);
        },
      );
    });
  }

  void _editMessage(String messageId, String newMessage) {
    if (widget.conversation.id != null) {
      ref.read(editMessageNotifier.notifier).editMessage(
            conversationId: widget.conversation.id!,
            messageId: messageId,
            newMessage: newMessage,
          );
    }
  }

  void _updatePresence(bool isOnline) {
    if (widget.conversation.id != null) {
      ref.read(userPresenceNotifier.notifier).updatePresence(
            conversationId: widget.conversation.id!,
            isOnline: isOnline,
          );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Helper method to check if date headers should be shown
  bool _shouldShowDateHeader(int index, List<ConversationMessageDto> messages) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    if (currentMessage.createdAt == null || previousMessage.createdAt == null) {
      return false;
    }

    final currentDate = DateTime(
      currentMessage.createdAt!.year,
      currentMessage.createdAt!.month,
      currentMessage.createdAt!.day,
    );

    final previousDate = DateTime(
      previousMessage.createdAt!.year,
      previousMessage.createdAt!.month,
      previousMessage.createdAt!.day,
    );

    return currentDate != previousDate;
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = widget.conversation.id != null
        ? ref.watch(fetchMessagesProvider(widget.conversation.id!))
        : const AsyncValue<List<ConversationMessageDto>>.data([]);

    // Use the new Pusher-integrated typing indicators
    final isTyping = widget.conversation.id != null
        ? ref.watch(isAnyoneTypingProvider(widget.conversation.id!))
        : false;

    // Listen to send message result
    ref.listen(sendMessageNotifier, (_, value) {
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
        // Clear all pending messages on error
        if (widget.conversation.id != null) {
          ref.read(pendingMessagesProvider(widget.conversation.id!).notifier).state = [];
        }
      } else if (value is AsyncData && value.value != null) {
        // Move from pending to sent messages
        if (widget.conversation.id != null) {
          final serverMessage = value.value!;

          // Clear pending messages
          ref.read(pendingMessagesProvider(widget.conversation.id!).notifier).state = [];

          // Add to sent messages (these will show until they appear in the main list)
          final currentSent = ref.read(sentMessagesProvider(widget.conversation.id!));
          ref.read(sentMessagesProvider(widget.conversation.id!).notifier).state = [
            ...currentSent,
            serverMessage,
          ];
        }
        _scrollToBottom();
      }
    });

    // Listen to send message with attachment result
    ref.listen(sendMessageWithAttachmentNotifier, (_, value) {
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
        // Clear all pending messages on error
        if (widget.conversation.id != null) {
          ref.read(pendingMessagesProvider(widget.conversation.id!).notifier).state = [];
        }
      } else if (value is AsyncData && value.value != null) {
        // Move from pending to sent messages
        if (widget.conversation.id != null) {
          final serverMessage = value.value!;

          // Clear pending messages
          ref.read(pendingMessagesProvider(widget.conversation.id!).notifier).state = [];

          // Add to sent messages
          final currentSent = ref.read(sentMessagesProvider(widget.conversation.id!));
          ref.read(sentMessagesProvider(widget.conversation.id!).notifier).state = [
            ...currentSent,
            serverMessage,
          ];
        }
        _scrollToBottom();
      }
    });

    // Listen to edit message result
    ref.listen(editMessageNotifier, (_, value) {
      if (value is AsyncError) {
        ToastDialog.showError('Failed to edit message: ${value.error}', context);
      } else if (value is AsyncData) {
        ToastDialog.showSuccess('Message edited successfully', context);
      }
    });

    // Listen to mark messages as read result
    ref.listen(markMessagesReadNotifier, (_, value) {
      if (value is AsyncError) {
        // Silently handle read receipt errors as they're not critical
        debugPrint('Failed to mark messages as read: ${value.error}');
      }
    });

    // Listen for new messages received via Pusher and mark as read if in conversation
    if (widget.conversation.id != null) {
      ref.listen(fetchMessagesProvider(widget.conversation.id!), (previous, next) {
        next.whenData((currentMessages) {
          // Check if there are new messages compared to previous state
          previous?.whenData((previousMessages) {
            if (currentMessages.length > previousMessages.length) {
              log('New message received, marking as read');
              // Get the last message and mark it as read
              final lastMessage = currentMessages.last;
              if (lastMessage.id != null && lastMessage.senderId != currentUserId) {
                log('Auto-marking received message as read: ${lastMessage.id!}');
                ref.read(markMessagesReadNotifier.notifier).markMessagesAsRead(
                      conversationId: widget.conversation.id!,
                      lastReadMessageId: lastMessage.id!,
                    );
              }
            }
          });
        });
      });
    }

    // Listen to Marking Delivery Completed - Time Based
    ref.listen(timeBasedMarkAsCompletedProvider, (_, value) {
      if (value is AsyncData) {
        context.push(
          BookingCompleteView(bookingId: widget.conversation.bookingId ?? ''),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    // Listen to Update Time Based Deliverable Status
    ref.listen(updateCreatorBookingStatusProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();

        ToastDialog.showSuccess('Booking Status Updated', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    // Listen to Marking Delivery Completed - Delivery Based
    ref.listen(deliveryBasedMarkAsCompletedProvider, (_, value) {
      if (value is AsyncData<(bool, bool)>) {
        if (value.value.$1) {
          context.push(
            BookingCompleteView(bookingId: widget.conversation.bookingId ?? ''),
          );
        } else {
          if (value.value.$2) {
            ToastDialog.showSuccess('Booking marked as completed', context);
          } else {
            ToastDialog.showSuccess('Revision successfully requested', context);
          }
        }
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    if (!_tourStarted) {
      _tourStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showcaseView.startShowCase([
          TourKeys.chatInput,
          TourKeys.chatActionButtons,
        ]);
      });
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Send user presence (offline) when exiting conversation
        _updatePresence(false);
      },
      child: OverlayLoadingIndicator(
        isLoading: (widget.conversation.bookingId != null
                ? ref
                    .watch(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''))
                    .isLoading
                : false) ||
            ref.watch(timeBasedMarkAsCompletedProvider).isLoading ||
            ref.watch(deliveryBasedMarkAsCompletedProvider).isLoading,
        text: 'Loading...',
        child: Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            centerTitle: false,
            title: ChatAppBarTitle(
              conversation: widget.conversation,
            ),
            actions: [
              GuardedShowcase(
                showcaseKey: TourKeys.chatActionButtons,
                description:
                    'Tap here to update booking status, request extensions, or report issues.',
                targetBorderRadius: BorderRadius.circular(8),
                child: IconButton(
                  key: _menuButtonKey,
                  icon: const Icon(Icons.more_vert, color: AppColors.icons),
                  onPressed: () {
                    if (widget.conversation.bookingId != null) {
                      _showChatMenu();
                    } else {
                      ToastDialog.showError(
                        "Conversation is closed until there's an active booking",
                        context,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: _showScrollToBottomButton
              ? Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.highlightCoral,
                    onPressed: _scrollToBottom,
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : null,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chat List
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    // Get pending and sent messages
                    final pendingMessages = widget.conversation.id != null
                        ? ref.watch(pendingMessagesProvider(widget.conversation.id!))
                        : <ConversationMessageDto>[];

                    final sentMessages = widget.conversation.id != null
                        ? ref.watch(sentMessagesProvider(widget.conversation.id!))
                        : <ConversationMessageDto>[];

                    // Filter out sent messages that are already in the main messages list
                    final sentMessageIds = messages.map((m) => m.id).toSet();
                    final filteredSentMessages =
                        sentMessages.where((msg) => !sentMessageIds.contains(msg.id)).toList();

                    // Clear sent messages that are now in main list
                    if (widget.conversation.id != null &&
                        filteredSentMessages.length < sentMessages.length) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(sentMessagesProvider(widget.conversation.id!).notifier).state =
                            filteredSentMessages;
                      });
                    }

                    // Combine: real messages + filtered sent messages + pending messages
                    final allMessages = [...messages, ...filteredSentMessages, ...pendingMessages];

                    if (allMessages.isEmpty) {
                      return const EmptyMessagesWidget();
                    }

                    // Scroll to bottom after first load only
                    if (!_hasScrolledToBottom) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                        _hasScrolledToBottom = true;
                      });
                    }

                    return Scrollbar(
                      controller: scrollController,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: allMessages.length + (isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < allMessages.length) {
                            final message = allMessages[index];
                            final isMe = message.senderId == currentUserId;
                            final showDateHeader = _shouldShowDateHeader(index, allMessages);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showDateHeader && message.createdAt != null)
                                  ChatDateHeader(date: message.createdAt!),
                                MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  currentUserId: currentUserId,
                                  onEdit: (messageId, newMessage) =>
                                      _editMessage(messageId, newMessage),
                                  onMarkAsRead: () => _markMessagesAsRead(),
                                ),
                              ],
                            );
                          } else {
                            // Typing indicator with enhanced text
                            return TypingIndicator(
                              senderName:
                                  widget.conversation.otherUser?.name?.split(' ').first ?? 'User',
                            );
                          }
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  error: (error, stack) => ChatErrorWidget(
                    onRetry: () {
                      if (widget.conversation.id != null) {
                        ref.invalidate(fetchMessagesProvider(widget.conversation.id!));
                      }
                    },
                  ),
                ),
              ),

              // Chat Input Field
              GuardedShowcase(
                showcaseKey: TourKeys.chatInput,
                description: 'Use chat to share files, links, and discuss job details.',
                targetBorderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SafeArea(
                    child: widget.conversation.bookingId == null
                        ? Text(
                            "Conversation is closed until there's an active booking",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.body),
                          )
                        : ChatInputField(
                            readOnly: widget.conversation.bookingId == null,
                            controller: messageController,
                            onSend: _sendMessage,
                            onAttachment: () {
                              if (widget.conversation.bookingId != null) {
                                _onAttachment();
                              } else {
                                ToastDialog.showError(
                                  "Conversation is closed until there's an active booking",
                                  context,
                                );
                              }
                            },
                            onChanged: _onTyping,
                            onTap: () {
                              if (widget.conversation.bookingId == null) {
                                ToastDialog.showError(
                                  "Conversation is closed until there's an active booking",
                                  context,
                                );
                              }
                            },
                            hintText: 'Type a message...',
                            // Changed from isSending to false
                            isLoading: false,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show Chat Menu
  void _showChatMenu() {
    final menuItems = ChatMenuController.createDefaultMenuItems(
      isCreator: widget.conversation.isCreator == true,
      showExtensionIndicator: (ref
                      .watch(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''))
                      .value
                      ?.extensionRequests !=
                  null &&
              ref
                  .watch(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''))
                  .value!
                  .extensionRequests!
                  .isNotEmpty)
          ? (ref
                  .watch(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''))
                  .value!
                  .extensionRequests!
                  .last
                  .status ==
              'pending')
          : false,
      viewProfile: () {
        context.push(
          FetchedCreatorProfileView(
            creatorId: widget.conversation.otherUser!.id ?? '',
            creatorName: widget.conversation.otherUser?.name ?? 'Unknown User',
          ),
        );
      },
      viewBooking: () {
        context.push(
          BookingDetailsView(
            bookingId: widget.conversation.bookingId,
            isSent: widget.conversation.isCreator == false,
            fromChat: true,
          ),
        );
      },
      markBookingCompleted: () {
        // Always Refresh the Booking
        ref.invalidate(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''));

        ref
            .read(fetchBookingDetailsProvider(widget.conversation.bookingId ?? '').future)
            .then((booking) async {
          // If Booking is Time Based
          if (booking.bookingType == 'time-based') {
            if (!mounted) return;

            bool result = await AppBottomSheet.showBottomSheet(
              context,
              widget: const MarkCompletedSheet(),
            );

            if (result) {
              ref.read(timeBasedMarkAsCompletedProvider.notifier).markAsCompletedTimeBased(
                    bookingId: widget.conversation.bookingId ?? '',
                  );
            }
          } else {
            if (!mounted) return;

            String? deliverableId = await AppBottomSheet.showBottomSheet(
              context,
              widget: MarkDeliveryCompletedSheet(
                bookingId: widget.conversation.bookingId ?? '',
                deliverables: booking.deliverables ?? [],
              ),
            );

            if (deliverableId != null) {
              ref.read(deliveryBasedMarkAsCompletedProvider.notifier).markAsCompletedDeliveryBased(
                    bookingId: widget.conversation.bookingId ?? '',
                    deliverableId: deliverableId,
                    action: 'approve',
                  );
            }
          }
        });
      },
      updateDeliverableStatus: () {
        // Always Refresh the Booking
        ref.invalidate(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''));

        ref
            .read(fetchBookingDetailsProvider(widget.conversation.bookingId ?? '').future)
            .then((booking) async {
          // If Booking is Time Based
          if (booking.bookingType == 'time-based') {
            if (!mounted) return;

            String result = await AppBottomSheet.showBottomSheet(
              context,
              widget: const UpdateDeliverableStatusSheet(
                status: "In Progress",
              ),
            );

            if (result.isNotEmpty) {
              ref.read(updateCreatorBookingStatusProvider.notifier).updateBookingStatus(
                    bookingId: widget.conversation.bookingId ?? '',
                    status: result.toLowerCase().replaceAll(' ', '_'),
                  );
            }
          } else {
            if (!mounted) return;

            context.push(
              UpdateCreatorDeliverableSheet(
                bookingId: widget.conversation.bookingId ?? '',
              ),
            );
          }
        });
      },
      requestExtension: () {
        // Always Refresh the Booking
        ref.invalidate(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''));

        ref
            .read(fetchBookingDetailsProvider(widget.conversation.bookingId ?? '').future)
            .then((booking) async {
          if (!mounted) return;

          AppBottomSheet.showBottomSheet(
            context,
            widget: RequestExtensionSheet(
              booking: booking,
            ),
          );
        });
      },
      viewExtensionRequest: () {
        // Always Refresh the Booking
        ref.invalidate(fetchBookingDetailsProvider(widget.conversation.bookingId ?? ''));

        ref
            .read(fetchBookingDetailsProvider(widget.conversation.bookingId ?? '').future)
            .then((booking) async {
          if (!mounted) return;

          if ((booking.extensionRequests?.isEmpty == true) ||
              ((booking.extensionRequests?.isNotEmpty == true) &&
                  (booking.extensionRequests?.last.status != 'pending'))) {
            ToastDialog.showError("No extension request yet", context);
            return;
          }

          AppBottomSheet.showBottomSheet(
            context,
            widget: ViewExtensionSheet(
              booking: booking,
              isLastRequest: true,
            ),
          );
        });
      },
      reportAccount: () {
        AppBottomSheet.showBottomSheet(
          context,
          widget: ReportCreatorAccountSheet(
            userId: widget.conversation.otherUser?.id ?? '',
          ),
        );
      },
      reportDispute: () {
        AppBottomSheet.showBottomSheet(
          context,
          widget: ReportBookingSheet(
            userId: widget.conversation.otherUser?.id ?? '',
            bookingId: widget.conversation.bookingId ?? '',
          ),
        );
      },
    );

    ChatMenuController.showProfileMenu(
      context: context,
      buttonKey: _menuButtonKey,
      menuItems: menuItems,
    );
  }
}
