import 'package:flutter/material.dart';
import 'package:kita_kerja/lib/utils.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AuthLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.background,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: Utils.screenHeigth,
                color: Utils.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 400,
                      child: ClipRRect(
                        child: title.contains('Forgot')
                            ? Image.asset('assets/img/confused.png')
                            : Image.asset('assets/img/auth-icon.png'),
                      ),
                    ),
                    Utils.mediumSpace,
                    Text(
                      'Selamat Datang di Kerja Kita',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Kelola tenaga kerja perusahaan anda dengan mudah dan sistematis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
