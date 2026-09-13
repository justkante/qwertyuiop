import 'dart:io';
import 'dart:ui' as ui;
import 'package:creatify_mobile/core/utils/app_func_utils.dart';
import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptExportService {
  /// Export receipt as PDF
  static Future<void> exportAsPdf(
    TransactionItemDto transactionDetails,
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final userData = ref.watch(userControllerProvider);

      // Load the logo
      final ByteData logoData = await rootBundle.load(AppImages.splashImage);
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      // Load Transction Image
      final ByteData transactionImageData = await rootBundle.load(AppImages.transactionSuccessful);
      final Uint8List transactionImageBytes = transactionImageData.buffer.asUint8List();

      // Create PDF document
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf')),
            bold: pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf')),
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo at top left with clickable link
                pw.UrlLink(
                  destination: 'https://creatifyapp.com/',
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 80,
                    height: 80,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Payment Details Title
                pw.Center(
                  child: pw.Text(
                    'Payment Details',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),

                // Transaction icon placeholder (centered circle)
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(transactionImageBytes),
                    width: 130,
                    height: 130,
                  ),
                ),
                pw.SizedBox(height: 30),

                // Transaction details
                _buildPdfRow(
                  'Type',
                  transactionDetails.type?.replaceAll('_', ' ').toTitleCase() ?? '',
                ),
                _buildPdfRow(
                  'Cost',
                  (transactionDetails.amount ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''),
                ),
                _buildPdfRow(
                  'Gateway Fee',
                  (transactionDetails.gatewayFee ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''),
                ),
                _buildPdfRow(
                  'Platform Fee',
                  (transactionDetails.platformFee ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''),
                ),
                _buildPdfRow(
                  'Penalty Fee',
                  (transactionDetails.penaltyFee ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''),
                ),
                _buildPdfRow(
                  'Transaction ID',
                  transactionDetails.paymentReference ?? '',
                ),
                _buildPdfRow(
                  'Date',
                  transactionDetails.paidAt == null
                      ? transactionDetails.createdAt?.transactionDate() ?? ''
                      : transactionDetails.paidAt!.transactionDate(),
                ),
                _buildPdfRow(
                  'Status',
                  transactionDetails.status?.toTitleCase() ?? '',
                  valueColor: _getStatusColor(transactionDetails.status),
                ),
                pw.SizedBox(height: 15),

                // Final Payout box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F9FAFB'),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Final Payout',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        (transactionDetails.netAmount ?? 0)
                            .amountWithCurrency(userData.primaryCurrency ?? ''),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#10B981'),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),

                // Footer with contact info
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Having issues with this transaction?',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.UrlLink(
                    destination: 'mailto:info@creatifyapp.com',
                    child: pw.Text(
                      'Contact us at info@creatifyapp.com',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColor.fromHex('#14B8A6'),
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Show Success Toast
      if (!context.mounted) return;
      ToastDialog.showSuccess('Generating PDF...', context);

      // Save PDF to temporary directory
      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File(
          '${output.path}/transaction_receipt_${transactionDetails.paymentReference ?? timestamp}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!context.mounted) return;

      // Share the PDF
      await AppUtils.shareFile(file, context);
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      rethrow;
    }
  }

  /// Export receipt as PNG
  static Future<void> exportAsPng(
    BuildContext context,
    TransactionItemDto transactionDetails,
    WidgetRef ref,
  ) async {
    try {
      // Create a GlobalKey to capture the widget
      final GlobalKey repaintBoundaryKey = GlobalKey();

      // Build the widget tree
      final widget = RepaintBoundary(
        key: repaintBoundaryKey,
        child: buildReceiptWidget(
          transactionDetails: transactionDetails,
          context: context,
          ref: ref,
        ),
      );

      // Create an overlay entry to render the widget off-screen
      OverlayEntry? overlayEntry;
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000,
          top: -10000,
          child: Material(
            child: Container(
              width: 400,
              color: Colors.white,
              child: widget,
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry);

      // Wait for the widget to be rendered
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture the widget as image
      RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Show Success Toast
      if (!context.mounted) return;
      ToastDialog.showSuccess('Generating PNG...', context);

      // Save to temporary directory
      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File(
          '${output.path}/transaction_receipt_${transactionDetails.paymentReference ?? timestamp}.png');
      await file.writeAsBytes(pngBytes);

      if (!context.mounted) return;

      await AppUtils.shareFile(file, context);
    } catch (e) {
      debugPrint('Error exporting PNG: $e');
      rethrow;
    }
  }

  /// Helper method to build PDF row
  static pw.Widget _buildPdfRow(
    String title,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: valueColor ?? PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color for PDF
  static PdfColor _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return PdfColor.fromHex('#F59E0B');
      case 'failed':
        return PdfColor.fromHex('#EF4444');
      case 'successful':
        return PdfColor.fromHex('#10B981');
      default:
        return PdfColors.grey700;
    }
  }

  /// Widget for PNG export - wraps the transaction details in a RepaintBoundary
  static Widget buildReceiptWidget({
    required TransactionItemDto transactionDetails,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final userData = ref.watch(userControllerProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo at top left
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () async {
                AppUtils.openLink(SocialPlatform.website);
              },
              child: Image.asset(
                AppImages.splashImage,
                width: 60,
                height: 60,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Payment Details Title
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.subHeading,
            ),
          ),
          const SizedBox(height: 40),

          // Transaction icon
          Image.asset(
            AppImages.transactionSuccessful,
            width: 130,
            height: 130,
          ),
          const SizedBox(height: 30),

          // Transaction details
          for (var details in [
            ('Type', transactionDetails.type?.replaceAll('_', ' ').toTitleCase() ?? ''),
            (
              'Cost',
              (transactionDetails.amount ?? 0).amountWithCurrency(userData.primaryCurrency ?? '')
            ),
            (
              'Gateway Fee',
              ((transactionDetails.gatewayFee ?? 0)
                  .amountWithCurrency(userData.primaryCurrency ?? ''))
            ),
            (
              'Platform Fee',
              ((transactionDetails.platformFee ?? 0)
                  .amountWithCurrency(userData.primaryCurrency ?? ''))
            ),
            (
              'Penalty Fee',
              ((transactionDetails.penaltyFee ?? 0)
                  .amountWithCurrency(userData.primaryCurrency ?? ''))
            ),
            ('Transaction ID', transactionDetails.paymentReference ?? ''),
            (
              'Date',
              transactionDetails.paidAt == null
                  ? transactionDetails.createdAt?.transactionDate() ?? ''
                  : transactionDetails.paidAt!.transactionDate()
            ),
            ('Status', transactionDetails.status?.toTitleCase() ?? ''),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildRow(
                details.$1,
                details.$2,
                transactionDetails.status,
              ),
            ),
          const SizedBox(height: 15),

          // Final Payout box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Final Payout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.subHeading,
                  ),
                ),
                Text(
                  (transactionDetails.netAmount ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.highlightGreen,
                    fontFamily: FontFamily.inter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Footer divider
          const Divider(),
          const SizedBox(height: 10),

          // Footer with contact info
          const Text(
            'Having issues with this transaction?',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subHeading,
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              AppUtils.openLink(SocialPlatform.email);
            },
            child: const Text(
              'Contact us at info@creatifyapp.com',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget to build row
  static Widget _buildRow(String title, String value, String? status) {
    Color? valueColor;
    if (title == 'Status') {
      valueColor = switch (status) {
        'pending' => AppColors.highlightYellow,
        'failed' => AppColors.highlightRed,
        'successful' => AppColors.highlightGreen,
        _ => AppColors.subHeading,
      };
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.subHeading,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.inter,
              color: valueColor ?? AppColors.subHeading,
            ),
          ),
        ),
      ],
    );
  }
}
