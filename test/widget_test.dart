// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:has/main.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('MyApp creates MaterialApp with correct settings',
        (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that MaterialApp is created
      expect(find.byType(MaterialApp), findsOneWidget);

      // Find the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify basic app settings
      expect(materialApp.debugShowCheckedModeBanner, false);
      expect(materialApp.initialRoute, '/login');
    });

    testWidgets('Login screen is displayed initially', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for all async operations to complete
      await tester.pumpAndSettle();

      // Verify that we're on the login screen
      expect(find.byType(CroppedBackgroundScreen), findsOneWidget);
    });

    testWidgets('Basic login elements are present', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify basic login form elements exist
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  group('CreateAccountScreen Tests', () {
    testWidgets('Create account form elements are present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('Form validation works for empty fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );

      // Try to register with empty fields
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Should show error message
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('Password mismatch validation works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );

      // Fill form with mismatched passwords
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(
        find.widgetWithText(TextField, 'Password').first,
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        'password456',
      );

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('ForgetPasswordScreen Tests', () {
    testWidgets('Forget password form elements are present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgetPasswordScreen(),
        ),
      );

      expect(find.text('Forget Password'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('Empty email validation works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgetPasswordScreen(),
        ),
      );

      // Try to send reset link with empty email
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
