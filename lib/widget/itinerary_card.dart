// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onTap: () {
        FocusScope.of(parentContext).unfocus();
        final itineraryProvider =
            Provider.of<ItineraryProvider>(context, listen: false);
        itineraryProvider.initItinerary(itinerary);

        snackbarHandler.removeCurrentSnackBar();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const AddDays();
        }));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: AppTheme.softCardDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: CustomColor.whiteColor,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day count badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColor.lightCoolGray,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                itinerary.days.length > 1
                                    ? '${itinerary.days.length} Days'
                                    : '${itinerary.days.length} Day',
                                style: primaryTextStyle.copyWith(
                                  fontWeight: semibold,
                                  color: CustomColor.boardroomNavy,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              itinerary.title,
                              style: headingTextStyle.copyWith(
                                fontWeight: semibold,
                                fontSize: 22,
                                color: CustomColor.boardroomNavy,
                                letterSpacing: -0.44,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 40,
                        thickness: 1,
                        indent: 4,
                        endIndent: 4,
                        color: CustomColor.lightCoolGray,
                      ),
                      // Date column
                      SizedBox(
                        width: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MULAI',
                              style: primaryTextStyle.copyWith(
                                fontWeight: semibold,
                                fontSize: 10,
                                color: CustomColor.brandElectric,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppHelper.formatDate(itinerary.days.first.date),
                              style: primaryTextStyle.copyWith(
                                fontWeight: medium,
                                fontSize: 13,
                                color: CustomColor.pitchBlack,
                              ),
                            ),
                            if (itinerary.days.length > 1) ...[
                              const SizedBox(height: 12),
                              Text(
                                'SELESAI',
                                style: primaryTextStyle.copyWith(
                                  fontWeight: semibold,
                                  fontSize: 10,
                                  color: CustomColor.brandElectric,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppHelper.formatDate(itinerary.days.last.date),
                                style: primaryTextStyle.copyWith(
                                  fontWeight: medium,
                                  fontSize: 13,
                                  color: CustomColor.pitchBlack,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 28), // space for delete icon
                    ],
                  ),
                ),
                // Delete button
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
                          content: const Text("Item dihapus!"),
                          action: SnackBarAction(
                            label: "Undo",
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
                      Icons.delete_outline,
                      size: 18,
                      color: CustomColor.inputBorderGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
