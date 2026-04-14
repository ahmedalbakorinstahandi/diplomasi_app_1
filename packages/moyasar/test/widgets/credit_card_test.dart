import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moyasar/moyasar.dart';

Widget createTestableApp(
    {required Localization locale,
    required bool tokenizeCard,
    required bool manual}) {
  final paymentConfig = PaymentConfig(
      publishableApiKey: "api_key",
      amount: 123,
      description: "Coffee",
      creditCard: CreditCardConfig(saveCard: tokenizeCard, manual: manual));

  void onPaymentResult() {}

  return MaterialApp(
      home: Scaffold(
          body: CreditCard(
              locale: locale,
              config: paymentConfig,
              onPaymentResult: onPaymentResult)));
}

void main() {
  group('credit card', () {
    testWidgets('should build pay row with USD amount', (tester) async {
      const locale = Localization.en();

      await tester.pumpWidget(createTestableApp(
          locale: locale, tokenizeCard: false, manual: false));

      expect(find.byType(CreditCard), findsOneWidget);
      expect(find.text('${locale.pay} '), findsOneWidget);
      expect(find.text('1.23'), findsOneWidget);
    });

    testWidgets('should show notice about saving credit card data.',
        (tester) async {
      const locale = Localization.en();

      await tester.pumpWidget(
          createTestableApp(locale: locale, tokenizeCard: true, manual: false));

      expect(find.text(locale.saveCardNotice), findsOneWidget);
    });

    testWidgets('should not show notice about saving credit card data.',
        (tester) async {
      const locale = Localization.en();

      await tester.pumpWidget(createTestableApp(
          locale: locale, tokenizeCard: false, manual: false));

      expect(find.text(locale.saveCardNotice), findsNothing);
    });
  });
}
