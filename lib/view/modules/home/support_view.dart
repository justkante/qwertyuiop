import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SupportView extends ConsumerStatefulWidget {
  const SupportView({super.key});

  @override
  ConsumerState<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends ConsumerState<SupportView> {
  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Support',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: Tawk(
        directChatLink: 'https://tawk.to/chat/6990c7b941fe0b1c3139e8e8/1jheoob8j',
        visitor: TawkVisitor(
          name: userData.name ?? 'Creatify User',
          email: userData.email ?? '',
        ),
        onLoad: () {
          debugPrint('Hello Tawk!');
        },
        onLinkTap: (String url) {
          debugPrint(url);
        },
        placeholder: const Center(
          child: Text('Loading...'),
        ),
      ),
    );
  }
}
