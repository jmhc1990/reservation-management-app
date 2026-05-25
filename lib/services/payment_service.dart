import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static const _secretKey = String.fromEnvironment('STRIPE_SECRET_KEY');
  static const _publishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static void init() {
    Stripe.publishableKey = _publishableKey;
  }

  // Devuelve true si el pago se completó correctamente
  Future<bool> processPayment({required int amountCents}) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountCents.toString(),
          'currency': 'eur',
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode != 200) return false;

      final clientSecret =
          json.decode(response.body)['client_secret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Zaitec Barber',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
