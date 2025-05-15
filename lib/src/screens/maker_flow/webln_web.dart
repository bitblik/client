import 'package:flutter_webln/flutter_webln.dart';

Future<bool> get isWeblnSupported async {
  try {
    await FlutterWebln.enable().then((_) {

    });
    final weblnValue = weblnDecode(FlutterWebln.webln);
    return weblnValue.isNotEmpty;
  } catch (e) {
    print("!!!!!!!!!!!!!$e");
    return false;
  }
}

Future<void> sendWeblnPayment(String invoice) async {
  await FlutterWebln.enable().then((bla) async {
    print("!!!! AFTER ENABLE result $bla");
    final result = FlutterWebln.sendPayment(invoice: invoice);
    if (result is Future) {
      await result;
    }
  });
}

void checkWeblnSupport(Function(bool) callback) async {
  callback(await isWeblnSupported);
}
