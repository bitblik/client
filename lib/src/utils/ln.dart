import 'dart:async'; // Import async for Timer
import 'dart:convert';

import 'package:bitblik/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

  // Add LNURL validation function
Future<String?> validateLightningAddress(String address, AppLocalizations strings) async {
  if (!address.contains('@')) {
    return strings.lightningAddressInvalid;
  }

  final parts = address.split('@');
  final username = parts[0];
  final domain = parts[1];

  try {
    final lnurlpUrl = Uri.https(domain, '/.well-known/lnurlp/$username');
    final response = await http.get(lnurlpUrl);

    // TODO: Add specific localization keys for these LNURL validation errors if needed
    if (response.statusCode != 200) {
      return '${strings.lightningAddressInvalid}: Could not fetch LNURL information';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] == 'ERROR') {
      return '${strings.lightningAddressInvalid}: ${data['reason']}';
    }

    if (data['tag'] != 'payRequest') {
      return '${strings.lightningAddressInvalid}: Not a valid LNURL-pay endpoint';
    }

    if (data['callback'] == null ||
        data['minSendable'] == null ||
        data['maxSendable'] == null) {
      return '${strings.lightningAddressInvalid}: Missing required LNURL-pay fields';
    }

    return null; // Validation passed
  } catch (e) {
    return '${strings.lightningAddressInvalid}: Could not verify LNURL endpoint';
  }
}
