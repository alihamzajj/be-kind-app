import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';

/// Opens the "share your kind act" sheet.
Future<void> showShareCardSheet(
  BuildContext context, {
  required int streak,
  required String taskTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ShareCardSheet(streak: streak, taskTitle: taskTitle),
  );
}

class ShareCardSheet extends StatefulWidget {
  const ShareCardSheet({
    required this.streak,
    required this.taskTitle,
    super.key,
  });

  final int streak;
  final String taskTitle;

  @override
  State<ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<ShareCardSheet> {
  static const _swatches = [
    ('Maroon', Color(0xFF3A0B12)),
    ('Forest', Color(0xFF163300)),
    ('Ink', Color(0xFF0E0F0C)),
  ];

  final _cardKey = GlobalKey();
  Color _bg = _swatches.first.$2;
  bool _busy = false;

  String get _caption =>
      'Day ${widget.streak} of kindness: ${widget.taskTitle} '
      '#BeKind #OneKindActEveryDay';

  Future<void> _shareImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final png = bytes!.buffer.asUint8List();

      final XFile file;
      if (kIsWeb) {
        file = XFile.fromData(png, mimeType: 'image/png', name: 'be_kind.png');
      } else {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/be_kind_day_${widget.streak}.png';
        await File(path).writeAsBytes(png);
        file = XFile(path, mimeType: 'image/png');
      }
      await SharePlus.instance.share(
        ShareParams(files: [file], text: _caption),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t share the card')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareText() =>
      SharePlus.instance.share(ShareParams(text: _caption));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share your kind act',
              style: textTheme.headlineSmall?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _ShareCard(
                      background: _bg,
                      streak: widget.streak,
                      taskTitle: widget.taskTitle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Card colour',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final (name, color) in _swatches) ...[
                  Semantics(
                    label: '$name card',
                    selected: _bg == color,
                    button: true,
                    child: GestureDetector(
                      onTap: () => setState(() => _bg = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: _bg == color
                                ? AppColors.lime
                                : AppColors.surface,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _bg == color
                                  ? AppColors.accent
                                  : AppColors.lineStrong,
                              spreadRadius: _bg == color ? 2 : 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _shareText,
                    child: const Text('Text only'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _shareImage,
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Share card'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Your private note is never included.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.background,
    required this.streak,
    required this.taskTitle,
  });

  final Color background;
  final int streak;
  final String taskTitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final s = c.maxWidth / 350; // scale everything with the card
        return ClipRRect(
          borderRadius: BorderRadius.circular(28 * s),
          child: Container(
            color: background,
            padding: EdgeInsets.all(26 * s),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -66 * s,
                  bottom: -66 * s,
                  child: Container(
                    width: 200 * s,
                    height: 200 * s,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lime,
                    ),
                  ),
                ),
                Positioned(
                  right: 14 * s,
                  bottom: 14 * s,
                  child: Container(
                    width: 70 * s,
                    height: 70 * s,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 34 * s,
                      color: AppColors.onLime,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11 * s,
                        vertical: 5 * s,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'DAY $streak OF KINDNESS',
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6 * s,
                          color: AppColors.onLime,
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * s),
                    SizedBox(
                      width: 250 * s,
                      child: Text(
                        'Today I did a kind act: $taskTitle',
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24 * s,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8 * s,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Be Kind',
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'One kind act, every day',
                      style: TextStyle(
                        fontSize: 12 * s,
                        color: const Color(0xFFE6D3D6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
