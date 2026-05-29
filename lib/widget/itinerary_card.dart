// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';

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
    final totalActivities = itinerary.days
        .fold<int>(0, (sum, day) => sum + day.activities.length);
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
            color: CustomColor.ocean900.withValues(alpha: 0.10),
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
                        InkWell(
                          onTap: () {
                            snackbarHandler.removeCurrentSnackBar();
                            final itineraryCopy = itinerary.copy();
                            dbProvider
                                .deleteItinerary(itinerary: itinerary)
                                .whenComplete(() {
                              onDelete?.call();
                              snackbarHandler.showSnackBar(
                                SnackBar(
                                  content: const Text('Item dihapus!'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      dbProvider.insertItinerary(
                                          itinerary: itineraryCopy);
                                      onDelete?.call();
                                      snackbarHandler.removeCurrentSnackBar();
                                    },
                                  ),
                                ),
                              );
                            });
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: CustomColor.muted,
                            ),
                          ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CustomColor.paper.withValues(alpha: 0.95),
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
