import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/core/utils/utils.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Utils.neoBlack,
            borderRadius: BorderRadius.zero,
            border: Utils.borderW,
            boxShadow: Utils.shadowSm,
          ),
          alignment: Alignment.center,
          child: Text(
            'K',
            style: GoogleFonts.spaceGrotesk(
              color: Utils.neoCream,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'KerjaKita',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Utils.neoBlack,
                height: 1.2,
              ),
            ),
            Text(
              'Manajemen Tenaga Kerja UMKM',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Utils.neoBlack,
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
