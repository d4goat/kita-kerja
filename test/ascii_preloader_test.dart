import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kita_kerja/widgets/ascii_preloader.dart';

void main() {
  group('rotateRight pure function unit tests', () {
    test('panjang hasil rotasi selalu sama dengan panjang string input', () {
      const patterns = [
        '=++==-----',
        '+++===---',
        '++==--',
        '-',
        '--==++',
        '+=-+=-',
      ];

      for (final p in patterns) {
        for (int step = 0; step <= 25; step++) {
          final rotated = rotateRight(p, step);
          expect(rotated.length, equals(p.length));
        }
      }
    });

    test('rotateRight(s, s.length) == s (satu putaran penuh kembali ke string semula)', () {
      const patterns = [
        '=++==-----',
        '+++===---',
        '++==--',
        '1234567890',
        '-+=',
      ];

      for (final p in patterns) {
        expect(rotateRight(p, p.length), equals(p));
        expect(rotateRight(p, p.length * 2), equals(p));
      }
    });

    test('rotasi ke kanan memindahkan karakter terakhir ke posisi pertama secara bertahap', () {
      const initial = '++==--';
      expect(rotateRight(initial, 1), equals('-++==-'));
      expect(rotateRight(initial, 2), equals('--++=='));
      expect(rotateRight(initial, 3), equals('=--++='));
      expect(rotateRight(initial, 4), equals('==--++'));
      expect(rotateRight(initial, 5), equals('+==--+'));
      expect(rotateRight(initial, 6), equals('++==--'));
    });

    test('hanya berisi karakter "-", "=", dan "+"', () {
      const defaultPattern = '=++==-----';
      final allowedChars = {'-', '=', '+'};

      for (int step = 0; step < 20; step++) {
        final frame = rotateRight(defaultPattern, step);
        for (int i = 0; i < frame.length; i++) {
          expect(
            allowedChars.contains(frame[i]),
            isTrue,
            reason: 'Karakter ${frame[i]} tidak valid pada step $step',
          );
        }
      }
    });
  });

  group('AsciiPreloader widget tests', () {
    testWidgets('menampilkan teks preloader dan melakukan cross-fade ke child', (tester) async {
      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF315CFF),
              primary: const Color(0xFF315CFF),
              onPrimary: Colors.white,
            ),
          ),
          home: AsciiPreloader(
            pattern: '=++==-----',
            minDuration: const Duration(milliseconds: 300),
            exitPauseDuration: const Duration(milliseconds: 50),
            fadeDuration: const Duration(milliseconds: 200),
            tickInterval: const Duration(milliseconds: 100),
            onFinished: () {
              finished = true;
            },
            child: const Scaffold(
              body: Text('Halaman Utama'),
            ),
          ),
        ),
      );

      // Verifikasi widget Text gelombang dan child ada
      expect(find.text('Halaman Utama'), findsOneWidget);
      expect(find.text('=++==-----'), findsOneWidget);

      // Verifikasi teks tidak memiliki garis bawah kuning (TextDecoration.none)
      final textWidget = tester.widget<Text>(find.text('=++==-----'));
      expect(textWidget.style?.decoration, equals(TextDecoration.none));

      // Lewati waktu animasi rotasi (tick 100ms)
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('-=++==----'), findsOneWidget);

      // Lewati waktu hingga selesai + cross-fade
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
    });
  });
}
