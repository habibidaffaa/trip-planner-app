// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:iterasi1/widget/text_dialog.dart';

class ItineraryCard extends StatelessWidget {
  final DatabaseProvider dbProvider;
  final ScaffoldMessengerState snackbarHandler;
  final Itinerary itinerary;
  final VoidCallback? onDelete;
  final BuildContext parentContext;

  const ItineraryCard({
    Key? key,
    required this.dbProvider,
    required this.snackbarHandler,
    required this.itinerary,
    this.onDelete,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalActivities =
        itinerary.days.fold<int>(0, (sum, day) => sum + day.activities.length);
    final nDays = itinerary.days.length;
    final nNights = nDays > 1 ? nDays - 1 : 0;

    return InkWell(
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: () {
        FocusScope.of(parentContext).unfocus();
        Provider.of<ItineraryProvider>(context, listen: false)
            .initItinerary(itinerary);
        snackbarHandler.removeCurrentSnackBar();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddDays()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: CustomColor.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomColor.ocean900.withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: CustomColor.shadowCard,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail or gradient header
              _ThumbnailHeader(
                thumbnailPath: itinerary.thumbnailPath,
                title: itinerary.title,
                nDays: nDays,
                nNights: nNights,
                seed: itinerary.title.hashCode,
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            itinerary.title,
                            style: displayStyle.copyWith(
                              fontSize: 20,
                              height: 1.2,
                              color: CustomColor.ocean900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 18,
                            color: CustomColor.muted,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: CustomColor.paper,
                          elevation: 4,
                          onSelected: (value) {
                            if (value == 'edit') _showEditDialog(context);
                            if (value == 'delete') _showDeleteConfirm(context);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: CustomColor.ocean900,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Edit nama',
                                    style: bodyStyle.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: CustomColor.danger,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Hapus',
                                    style: bodyStyle.copyWith(
                                      fontSize: 14,
                                      color: CustomColor.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (itinerary.days.isNotEmpty)
                      Text(
                        '${AppHelper.formatDate(itinerary.days.first.date)}'
                        '${nDays > 1 ? '  –  ${AppHelper.formatDate(itinerary.days.last.date)}' : ''}',
                        style: monoStyle.copyWith(
                          fontSize: 11,
                          color: CustomColor.muted,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalActivities aktivitas',
                      style: monoStyle.copyWith(
                        fontSize: 11,
                        color: CustomColor.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditItineraryDialog(
        initialTitle: itinerary.title,
        initialThumbnailPath: itinerary.thumbnailPath,
        onSave: (newTitle, newThumbnailPath) {
          final updated = itinerary.copy(
            title: newTitle,
            thumbnailPath: newThumbnailPath,
          );
          dbProvider.insertItinerary(itinerary: updated);
          onDelete?.call();
        },
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => IterasiConfirmDialog(
        title: 'Hapus itinerary?',
        message:
            'Itinerary "${itinerary.title}" akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
        confirmLabel: 'Hapus',
        onConfirm: () {
          dbProvider.deleteItinerary(itinerary: itinerary).whenComplete(() {
            onDelete?.call();
          });
        },
      ),
    );
  }
}

class _ThumbnailHeader extends StatelessWidget {
  final String? thumbnailPath;
  final String title;
  final int nDays;
  final int nNights;
  final int seed;

  const _ThumbnailHeader({
    required this.thumbnailPath,
    required this.title,
    required this.nDays,
    required this.nNights,
    required this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final hasThumb = thumbnailPath != null && File(thumbnailPath!).existsSync();
    return SizedBox(
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          hasThumb
              ? Image.file(File(thumbnailPath!), fit: BoxFit.cover)
              : _GradientHeader(seed: seed),
          // duration pill
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CustomColor.paper.withOpacity(0.95),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${nDays}D${nNights}N',
                style: monoStyle.copyWith(
                  fontSize: 11,
                  color: CustomColor.ocean900,
                  fontWeight: semibold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  final int seed;
  const _GradientHeader({required this.seed});

  static const _gradients = [
    // 0: terrace-green
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6F8A52), Color(0xFF3A5040)],
    ),
    // 1: bromo-orange (coral → ocean)
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [CustomColor.coral500, CustomColor.ocean900],
    ),
    // 2: komodo-blue (ocean → sand)
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [CustomColor.ocean900, CustomColor.sand300],
    ),
    // 3: yogya-brown
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B6F47), Color(0xFF5C4530)],
    ),
    // 4: jimbaran-sunset (coral-300 → ocean)
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE8A88A), CustomColor.ocean700],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _gradients[seed.abs() % _gradients.length],
      ),
    );
  }
}

/// Dialog untuk mengubah nama trip sekaligus foto cover (thumbnail).
class _EditItineraryDialog extends StatefulWidget {
  final String initialTitle;
  final String? initialThumbnailPath;
  final void Function(String title, String? thumbnailPath) onSave;

  const _EditItineraryDialog({
    required this.initialTitle,
    required this.initialThumbnailPath,
    required this.onSave,
  });

  @override
  State<_EditItineraryDialog> createState() => _EditItineraryDialogState();
}

class _EditItineraryDialogState extends State<_EditItineraryDialog> {
  late final TextEditingController _controller;
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _thumbnailPath = widget.initialThumbnailPath;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final xfile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) setState(() => _thumbnailPath = xfile.path);
  }

  bool get _hasThumb =>
      _thumbnailPath != null && File(_thumbnailPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CustomColor.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Edit trip',
        style: displayStyle.copyWith(fontSize: 20, color: CustomColor.ocean900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail picker slot
          GestureDetector(
            onTap: _pickThumbnail,
            child: _hasThumb
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 5 / 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(_thumbnailPath!), fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: CustomColor.ocean900.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Ganti foto',
                                style: bodyStyle.copyWith(
                                  fontSize: 11,
                                  color: CustomColor.paper,
                                  fontWeight: medium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CustomColor.ocean900.withOpacity(0.2),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_outlined,
                              color: CustomColor.muted, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            'Tambah foto cover (opsional)',
                            style: bodyStyle.copyWith(
                              fontSize: 12,
                              color: CustomColor.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLength: 25,
            style:
                bodyStyle.copyWith(fontSize: 14, color: CustomColor.ocean900),
            decoration: InputDecoration(
              hintText: 'Nama trip',
              hintStyle: bodyStyle.copyWith(
                color: CustomColor.muted,
                fontSize: 14,
              ),
              counterText: '',
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColor.coral500),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Batal & Simpan kept side by side (equal width).
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    side: BorderSide(
                      color: CustomColor.ocean900.withOpacity(0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: bodyStyle.copyWith(
                      color: CustomColor.ocean900,
                      fontWeight: medium,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final newTitle = _controller.text.trim();
                    if (newTitle.isNotEmpty) {
                      widget.onSave(newTitle, _thumbnailPath);
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.ocean900,
                    minimumSize: const Size(0, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: bodyStyle.copyWith(
                      color: CustomColor.paper,
                      fontWeight: semibold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
