import 'package:flutter/material.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:printing/printing.dart';

import 'make_pdf.dart';

class PdfPreviewPage extends StatelessWidget {
  final Itinerary itinerary;
  const PdfPreviewPage({Key? key, required this.itinerary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.paper,
      appBar: AppBar(
        backgroundColor: CustomColor.paper,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomColor.ocean900.withOpacity(0.25),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: CustomColor.ocean900,
              size: 20,
            ),
          ),
        ),
        title: Column(
          children: [
            IterasiKicker('pratinjau pdf', color: CustomColor.muted),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IterasiMono(
              'A4',
              style: const TextStyle(fontSize: 11),
              color: CustomColor.muted,
            ),
          ),
        ],
      ),
      body: PdfPreview(
        build: (context) => makePdf(itinerary),
      ),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //   decoration: BoxDecoration(
      //     color: CustomColor.paper,
      //     border: Border(
      //       top: BorderSide(
      //         color: CustomColor.ocean900.withOpacity(0.10),
      //       ),
      //     ),
      //   ),
      //   child: Row(
      //     children: [
      //       Expanded(
      //         child: OutlinedButton.icon(
      //           onPressed: () {},
      //           style: OutlinedButton.styleFrom(
      //             side: BorderSide(
      //               color: CustomColor.ocean900.withOpacity(0.25),
      //             ),
      //             padding: const EdgeInsets.symmetric(vertical: 14),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(100),
      //             ),
      //           ),
      //           icon: const Icon(
      //             Icons.print_outlined,
      //             size: 18,
      //             color: CustomColor.ocean900,
      //           ),
      //           label: Text(
      //             'Cetak',
      //             style: bodyStyle.copyWith(
      //               color: CustomColor.ocean900,
      //               fontWeight: medium,
      //             ),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //       Expanded(
      //         child: ElevatedButton.icon(
      //           onPressed: () {},
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: CustomColor.ocean900,
      //             padding: const EdgeInsets.symmetric(vertical: 14),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(100),
      //             ),
      //             elevation: 0,
      //           ),
      //           icon: const Icon(
      //             Icons.share_outlined,
      //             size: 18,
      //             color: Colors.white,
      //           ),
      //           label: Text(
      //             'Bagikan',
      //             style: bodyStyle.copyWith(
      //               color: Colors.white,
      //               fontWeight: medium,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
