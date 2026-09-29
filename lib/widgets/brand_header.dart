import 'package:flutter/material.dart';
import 'package:kita_kerja/lib/utils.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Utils.primary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Utils.border, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            'K',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'KerjaKita',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Utils.border,
                height: 1.2,
              ),
            ),
            Text(
              'Manajemen Tenaga Kerja UMKM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
