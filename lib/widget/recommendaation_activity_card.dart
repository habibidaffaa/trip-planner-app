import 'package:flutter/material.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';

class RecommendaationActivityCard extends StatelessWidget {
  final Activity data;

  const RecommendaationActivityCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColor.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColor.ocean900.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColor.shadowSoft,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.startActivityTime,
            style: monoStyle.copyWith(
              fontSize: 12,
              color: CustomColor.coral700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.activityName,
            style: bodyStyle.copyWith(
              fontWeight: medium,
              fontSize: 15,
              color: CustomColor.ocean900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            data.lokasi,
            style: monoStyle.copyWith(
              fontSize: 12,
              color: CustomColor.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${AppHelper.calculateDurationInMinutes(data.startActivityTime, data.endActivityTime)} min  ·  ${data.endActivityTime}',
            style: monoStyle.copyWith(
              fontSize: 11,
              color: CustomColor.muted,
            ),
          ),
        ],
      ),
    );
  }
}
