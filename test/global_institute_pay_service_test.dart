import 'package:flutter_test/flutter_test.dart';
import 'package:pasar_malam/core/services/global_institute_pay_service.dart';

void main() {
  test('builds Dompet Kampus Global payment deeplink', () {
    final url = GlobalInstitutePayService.buildDeeplinkUrl(
      orderId: 42,
      amount: 75000,
      description: 'Order #42',
    );

    final uri = Uri.parse(url);

    expect(uri.scheme, 'dompetkampus');
    expect(uri.host, 'pay');
    expect(uri.queryParameters['merchant_id'], 'MCH_PASAR_MALAM');
    expect(uri.queryParameters['amount'], '75000');
    expect(uri.queryParameters['reference'], 'INV-42');
    expect(uri.queryParameters['callback'], 'pasarmalam://payment-callback');
  });
}
