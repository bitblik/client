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
  print("!!!! BEFORE ENABLE");
  await FlutterWebln.enable();
  print("!!!! AFTER ENABLE");
  print("!!!! before payment invoice $invoice");
  final result = FlutterWebln.sendPayment(invoice: invoice);
  print("!!!! send payment result $result");
  if (result is Future) {
    print("!!!! send payment result ${ await result}");
  }
}

void checkWeblnSupport(Function(bool) callback) async {
  callback(await isWeblnSupported);
}
