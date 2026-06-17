import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iterasi1/model/create_itinerary_result.dart';
import 'package:iterasi1/resource/theme.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({super.key});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  String? _thumbnailPath;
  bool isEnable = false;
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final xfile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) setState(() => _thumbnailPath = xfile.path);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buat Itinerary Baru',
                    style: bodyStyle.copyWith(
                      fontWeight: semibold,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: CustomColor.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Thumbnail picker slot
              GestureDetector(
                onTap: _pickThumbnail,
                child: _thumbnailPath == null
                    ? Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CustomColor.ocean900.withOpacity(0.2),
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined,
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
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 5 / 3,
                          child: Image.file(
                            File(_thumbnailPath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              // Title field
              TextField(
                controller: titleController,
                maxLength: 25,
                keyboardType: TextInputType.name,
                maxLines: 1,
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.all(15),
                  hintText: 'Masukan Nama Trip Anda',
                  hintStyle: bodyStyle.copyWith(
                    fontSize: 14,
                    color: CustomColor.muted,
                  ),
                ).applyDefaults(Theme.of(context).inputDecorationTheme),
                style: bodyStyle.copyWith(
                  fontSize: 14,
                  color: CustomColor.ink,
                ),
                onChanged: (value) {
                  setModalState(() => isEnable = value.isNotEmpty);
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Maksimal 25 karakter',
                style: bodyStyle.copyWith(
                  fontSize: 12,
                  color: CustomColor.muted,
                ),
              ),
              const SizedBox(height: 16),

              // CTA button
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEnable
                      ? () async {
                          if (titleController.text.isEmpty) return;
                          setModalState(() => _isLoading = true);
                          Navigator.of(context).pop(
                            CreateItineraryResult(
                              title: titleController.text,
                              thumbnailPath: _thumbnailPath,
                            ),
                          );
                        }
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CustomColor.paper,
                          ),
                        )
                      : Text(
                          'Selanjutnya',
                          style: bodyStyle.copyWith(
                            color: CustomColor.paper,
                            fontWeight: semibold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
