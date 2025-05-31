import 'package:flutter_webln/flutter_webln.dart';

Future<bool> get isWeblnSupported async {
  try {
    await FlutterWebln.enable();
    final weblnValue = weblnDecode(FlutterWebln.webln);
    print("!!!!!!!!!!!!!: isWeblnSupported weblnValue: $weblnValue");
    if (weblnValue.isNotEmpty) {
      try {
        bool a = await FlutterWebln.getInfo().then(allowInterop((response) {
          print('[!] getInfo method is $response');
          if (response!=null) {
            return true;
          }
          return false;
        }));
        return a;
      } catch (error) {
        print('[!] Error in getInfo method is $error');
        return false;
      }
    }
    return false;
  } catch (e) {
    print("!!!!!!!!!!!!!: isWeblnSupported $e");
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
    print("!!!!!!!!!!!!! send payment: $e");
    rethrow;
  }
}

void checkWeblnSupport(Function(bool) callback) async {
  callback(await isWeblnSupported);
}
