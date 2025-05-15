import 'package:flutter_webln/flutter_webln.dart';

Future<bool> get isWeblnSupported async {
  try {
    await FlutterWebln.enable();
    final weblnValue = weblnDecode(FlutterWebln.webln);
    return weblnValue.isNotEmpty;
  } catch (e) {
    print("!!!!!!!!!!!!!$e");
    return false;
  }
}

Future<void> sendWeblnPayment(String invoice) async {
  try {
    await FlutterWebln.enable();
    final result = FlutterWebln.sendPayment(invoice: invoice);
    if (result is Future) {
      print("!!!! send payment result ${await result}");
    } else {
      print("!!!! send payment result $result");
    }
  } catch(e) {
    print("!!!!!!!!!!!!!$e");
    rethrow;
  }
}

void checkWeblnSupport(Function(bool) callback) async {
  callback(await isWeblnSupported);
}
