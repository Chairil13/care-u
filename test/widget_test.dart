// Widget test untuk CareU app.
// Test memverifikasi bahwa SplashScreen dan LoginScreen dapat di-render.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:care_u/providers/auth_provider.dart';
import 'package:care_u/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen menampilkan form email dan password',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Tunggu animasi
    await tester.pump(const Duration(milliseconds: 900));

    // Verifikasi elemen utama ada
    expect(find.text('CareU'), findsOneWidget);
    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2)); // email + password
  });
}
