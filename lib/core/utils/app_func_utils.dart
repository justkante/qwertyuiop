import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static Future<ShareResult> shareFile(File bytes, BuildContext context) async {
    final shots = XFile(bytes.path);

    // Share Position is needed on iOS 26
    final box = context.findRenderObject() as RenderBox?;

    final res = await SharePlus.instance.share(
      ShareParams(
        files: [shots],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
    return res;
  }

  static Future<void> shareLink(String link, BuildContext context) async {
    // Share Position is needed on iOS 26
    final box = context.findRenderObject() as RenderBox?;

    await HapticFeedback.mediumImpact();
    SharePlus.instance.share(
      ShareParams(
        uri: Uri.parse(link),
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  static Future<void> openLink(SocialPlatform platform, {String? value}) async {
    final urls = {
      SocialPlatform.email: Uri(
        scheme: 'mailto',
        path: 'info@creatifyapp.com',
        query: 'subject=Hello Creatify Support',
      ),
      SocialPlatform.website: Uri.parse('https://www.creatifyapp.com'),
    };

    final url = urls[platform];

    var urlx = url;

    if (!await launchUrl(urlx!, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

enum SocialPlatform {
  email,
  website,
}
