import 'dart:async';
import 'dart:io' show Platform; // Import Platform

import 'package:app_links/app_links.dart';
import 'package:bitblik/src/screens/maker_flow/maker_confirm_payment_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_invalid_blik_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_pay_invoice_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_success_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_wait_for_blik_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_wait_taker_screen.dart';
import 'package:bitblik/src/screens/taker_flow/taker_invalid_blik_screen.dart';
import 'package:bitblik/src/screens/taker_flow/taker_payment_failed_screen.dart';
import 'package:bitblik/src/screens/taker_flow/taker_payment_process_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Keep for GlobalMaterialLocalizations.delegates
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';
import 'package:ndk_rust_verifier/data_layer/repositories/verifiers/rust_event_verifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:url_launcher/url_launcher.dart';

import 'i18n/gen/strings.g.dart'; // Import Slang from new path
import 'src/models/offer.dart'; // Needed for OfferStatus enum
import 'src/providers/providers.dart';
import 'src/screens/faq_screen.dart'; // Import the FAQ screen
import 'src/screens/maker_flow/maker_amount_form.dart';
import 'src/screens/maker_flow/maker_conflict_screen.dart'; // Import the maker conflict screen
import 'src/screens/offer_details_screen.dart';
import 'src/screens/offer_list_screen.dart';
import 'src/screens/role_selection_screen.dart';
import 'src/screens/taker_flow/taker_conflict_screen.dart'; // Import the taker conflict screen
import 'src/screens/taker_flow/taker_submit_blik_screen.dart';
import 'src/screens/taker_flow/taker_wait_confirmation_screen.dart';

final double kMakerFeePercentage = 0.5;
final double kTakerFeePercentage = 0.5;
final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
late AppLocale appLocale;
final rustEventVerifier = RustEventVerifier();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AppScaffold(body: RoleSelectionScreen())),
      GoRoute(path: '/offers', builder: (context, state) => const AppScaffold(body: OfferListScreen())),
      GoRoute(
        path: '/offers/:id',
        builder: (context, state) {
          final offerId = state.pathParameters['id'];
          if (offerId == null) {
            // Or redirect to an error page
            return const AppScaffold(body: Center(child: Text('No offer ID provided.')));
          }
          return AppScaffold(body: OfferDetailsScreen(offerId: offerId));
        },
      ),
      GoRoute(path: '/create', builder: (context, state) => const AppScaffold(body: MakerAmountForm())),
      GoRoute(path: '/pay', builder: (context, state) => const AppScaffold(body: MakerPayInvoiceScreen())),
      GoRoute(path: '/wait-taker', builder: (context, state) => const AppScaffold(body: MakerWaitTakerScreen())),
      GoRoute(path: '/wait-blik', builder: (context, state) => const AppScaffold(body: MakerWaitForBlikScreen())),
      GoRoute(path: '/confirm-blik', builder: (context, state) => const AppScaffold(body: MakerConfirmPaymentScreen())),
      GoRoute(
        path: '/maker-success',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(body: MakerSuccessScreen(completedOffer: state.extra as Offer));
          }
        },
      ),

      GoRoute(
        path: '/submit-blik',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(body: TakerSubmitBlikScreen(initialOffer: state.extra as Offer));
          }
        },
      ),
      GoRoute(
        path: '/wait-confirmation',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(body: TakerWaitConfirmationScreen(offer: state.extra as Offer));
          }
        },
      ),
      GoRoute(
        path: '/taker-failed',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(body: TakerPaymentFailedScreen(offer: state.extra as Offer));
          }
        },
      ),
      GoRoute(path: '/paying-taker', builder: (context, state) => AppScaffold(body: TakerPaymentProcessScreen())),
      GoRoute(
        path: '/taker-invalid-blik',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(body: TakerInvalidBlikScreen(offer: state.extra as Offer));
          }
        },
      ),

      GoRoute(
        path: '/taker-conflict',
        builder: (context, state) => AppScaffold(body: TakerConflictScreen(offerId: state.extra as String)),
      ),
      GoRoute(
        path: '/maker-invalid-blik',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(body: MakerInvalidBlikScreen(offer: state.extra as Offer));
          }
        },
      ),
      GoRoute(
        path: '/maker-conflict',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(body: MakerConflictScreen(offer: state.extra as Offer));
          }
        },
      ),
      GoRoute(
        path: FaqScreen.routeName,
        builder:
            (context, state) => AppScaffold(
              body: const FaqScreen(),
              pageTitle: t.faq.screenTitle,
            ),
      ),
    ],
  );
});

Future<void> main() async {
  // Initialize FFI for desktop platforms
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  String? localeString = await asyncPrefs.getString('app_locale');
  if (localeString != null) {
    appLocale = localeString == 'pl' ? AppLocale.pl : AppLocale.en;
  } else {
    appLocale = AppLocaleUtils.findDeviceLocale();
  }
  LocaleSettings.setLocale(appLocale);
  runApp(
    TranslationProvider(
      // Wrap with TranslationProvider
      child: const ProviderScope(child: SafeArea(child: MyApp())),
    ),
  );
}

// Replace MyApp with a ConsumerStatefulWidget to handle deep links
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<Uri>? _sub;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    try {
      ref.read(keyServiceProvider);
      ref.read(apiServiceProvider);

      print('🚀 App initialized: API service and coordinator discovery started');
    } catch (e) {
      print('❌ Error during app initialization: $e');
    }

    // Initialize API service and start coordinator discovery
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(initializedApiServiceProvider.future);
        final coordinatorsAsync = ref.watch(discoveredCoordinatorsProvider);

        // Initialize the offer status subscription manager
        ref.read(offerStatusSubscriptionManagerProvider);

        print('🚀 App initialized: API service and coordinator discovery started');
      } catch (e) {
        print('❌ Error during app initialization: $e');
      }
    });

    // Only listen for deep links on Android/iOS, not web
    if (!kIsWeb) {
      _sub = _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            // Handle both /offers and #/offers
            final path = uri.path;
            final fragment = uri.fragment;
            final router = ref.read(routerProvider);
            if (path == '/offers' || fragment == '/offers') {
              kIsWeb ? router.go('/offers') : router.push('/offers');
            }
          }
        },
        onError: (err) {
          // Handle error
        },
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final t = Translations.of(context);

    return MaterialApp.router(
      title: t.app.title,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      locale: appLocale.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}

// AppScaffold to maintain consistent UI structure with AppBar and footer
class AppScaffold extends ConsumerStatefulWidget {
  final Widget body;
  final String? pageTitle; // Optional page title

  const AppScaffold({super.key, required this.body, this.pageTitle});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  String? _clientVersion;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _clientVersion = info.version;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showNekoInfoDialog(String pubKey) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.nekoInfo.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display bigger neko avatar at the top
                CachedNetworkImage(
                  imageUrl: 'https://robohash.org/$pubKey?set=set4',
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: 150,
                  // Bigger size compared to the 32x32 in the footer
                  height: 150,
                ),
                const SizedBox(height: 20),
                Text(t.nekoInfo.description),
                const SizedBox(height: 20),
                SelectableText(Nip19.encodePubKey(pubKey)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: Text(t.common.buttons.close), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  void _showGenerateNewKeyDialog() {
    final keyService = ref.read(keyServiceProvider);
    final activeOffer = ref.read(activeOfferProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.generateNewKey.title),
          content: Text(activeOffer != null ? t.generateNewKey.errors.activeOffer : t.generateNewKey.description),
          actions: <Widget>[
            TextButton(child: Text(t.common.buttons.cancel), onPressed: () => Navigator.of(context).pop()),
            if (activeOffer == null)
              TextButton(
                child: Text(t.generateNewKey.buttons.generate),
                onPressed: () async {
                  try {
                    await keyService.generateNewKeyPair();

                    // Clear the active offer when restoring a new key
                    await ref.read(activeOfferProvider.notifier).setActiveOffer(null);

                    // Invalidate providers to force re-initialization
                    ref.invalidate(keyServiceProvider);
                    ref.invalidate(apiServiceProvider);
                    ref.invalidate(initializedApiServiceProvider);
                    ref.invalidate(publicKeyProvider);
                    ref.invalidate(discoveredCoordinatorsProvider);

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    // Re-initialize services
                    await ref.read(initializedApiServiceProvider.future);

                    Navigator.of(context).pop(); // Close loading dialog
                    Navigator.of(context).pop(); // Close generate key dialog

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(t.generateNewKey.feedback.success)));
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('${t.generateNewKey.errors.failed}: ${e.toString()}')));
                  }
                },
              ),
          ],
        );
      },
    );
  }

  // --- Backup and Restore Dialogs ---

  void _showBackupDialog() {
    final keyService = ref.read(keyServiceProvider);
    final privateKey = keyService.privateKeyHex;
    if (privateKey == null) return;

    bool isRevealed = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(t.backup.title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(t.backup.description),
                    const SizedBox(height: 16),
                    SelectableText(
                      isRevealed
                          ? Nip19.encodePrivateKey(privateKey)
                          : '****************************************************************',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton.icon(
                  icon: Icon(isRevealed ? Icons.visibility_off : Icons.visibility),
                  label: Text(isRevealed ? t.common.buttons.hide : t.common.buttons.reveal),
                  onPressed: () {
                    setState(() {
                      isRevealed = !isRevealed;
                    });
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.copy),
                  label: Text(t.common.buttons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: Nip19.encodePrivateKey(privateKey)));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.backup.feedback.copied)));
                  },
                ),
                TextButton(
                  child: Text(t.common.buttons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRestoreDialog() {
    final keyService = ref.read(keyServiceProvider);
    final TextEditingController privateKeyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.restore.title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: privateKeyController,
              decoration: InputDecoration(labelText: t.restore.labels.privateKey, hintText: 'e.g., nsec1...'),
              validator: (value) {
                if (value == null || !Nip19.isPrivateKey(value)) {
                  return t.restore.errors.invalidKey;
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t.common.buttons.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(t.restore.buttons.restore),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    String pKey = Nip19.decode(privateKeyController.text);
                    await keyService.savePrivateKey(pKey);

                    // Clear the active offer when restoring a new key
                    await ref.read(activeOfferProvider.notifier).setActiveOffer(null);

                    // Invalidate providers to force re-initialization
                    ref.invalidate(keyServiceProvider);
                    ref.invalidate(apiServiceProvider);
                    ref.invalidate(initializedApiServiceProvider);
                    ref.invalidate(publicKeyProvider);
                    ref.invalidate(discoveredCoordinatorsProvider);

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    // Re-initialize services
                    await ref.read(initializedApiServiceProvider.future);

                    Navigator.of(context).pop(); // Close loading dialog
                    Navigator.of(context).pop(); // Close restore dialog

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.restore.feedback.success)));
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('${t.restore.errors.failed}: ${e.toString()}')));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final publicKeyAsync = ref.watch(publicKeyProvider);
    final String currentPath = GoRouterState.of(context).uri.toString();

    Widget appBarTitle;
    // bool canGoBack = GoRouter.of(context).canGoBack(); // Removed this line

    if (widget.pageTitle != null && widget.pageTitle!.isNotEmpty) {
      appBarTitle = Text(widget.pageTitle!);
    } else {
      appBarTitle = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            // Reset relevant state providers (but keep active offer)
            ref.read(holdInvoiceProvider.notifier).state = null;
            ref.read(paymentHashProvider.notifier).state = null;
            ref.read(receivedBlikCodeProvider.notifier).state = null;
            ref.read(errorProvider.notifier).state = null;
            ref.read(isLoadingProvider.notifier).state = false;
            ref.invalidate(availableOffersProvider);

            // Navigate to home
            context.go('/');
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.app.title,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(width: 4),
              Text(
                _clientVersion != null ? 'v$_clientVersion beta' : 'beta',
                style: const TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            (widget.pageTitle != null && widget.pageTitle!.isNotEmpty), // Show back button if pageTitle is present
        title: appBarTitle,
        // Add a divider at the bottom of the AppBar
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0),
        ),
        actions: [
          // Language Switcher Dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<AppLocale>(
              value: appLocale,
              icon: const SizedBox.shrink(),
              // Hide the dropdown arrow
              isDense: true,
              selectedItemBuilder: (BuildContext context) {
                // This controls what's shown when the dropdown is closed
                return AppLocale.values.map<Widget>((AppLocale locale) {
                  return Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(minWidth: 48),
                    child: const Icon(Icons.language, color: Colors.grey),
                  );
                }).toList();
              },
              onChanged: (AppLocale? newLocale) async {
                if (newLocale != null) {
                  await asyncPrefs.setString(
                    'app_locale',
                    newLocale.languageCode,
                  );
                  if (LocaleSettings.currentLocale.languageCode !=
                      newLocale.languageCode) {
                    appLocale =
                    newLocale.languageCode == 'pl'
                        ? AppLocale.pl
                        : AppLocale.en;
                    LocaleSettings.setLocale(appLocale);
                    // Force rebuild to update UI
                    if (mounted) {
                      setState(() {});
                    }
                  }
                }
              },
              items: AppLocale.values.map<DropdownMenuItem<AppLocale>>((AppLocale locale) {
                final String flagEmoji =
                locale.languageCode == 'en'
                    ? '🇬🇧'
                    : locale.languageCode == 'pl'
                    ? '🇵🇱'
                    : '';
                final String displayName =
                locale.languageCode == 'en'
                    ? 'EN'
                    : locale.languageCode == 'pl'
                    ? 'PL'
                    : locale.languageCode.toUpperCase();
                return DropdownMenuItem<AppLocale>(
                  value: locale,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        flagEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Flexible(

                        child: Text(
                          displayName,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Conditionally display Home icon if not on the main screen ('/')
          if (currentPath != '/')
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: t.common.buttons.goHome, // Use Slang for tooltip
              onPressed: () async {
                // Reset relevant state providers (but keep active offer)
                ref.read(holdInvoiceProvider.notifier).state = null;
                ref.read(paymentHashProvider.notifier).state = null;
                ref.read(receivedBlikCodeProvider.notifier).state = null;
                ref.read(errorProvider.notifier).state = null;
                ref.read(isLoadingProvider.notifier).state = false;
                ref.invalidate(availableOffersProvider);

                // Navigate to home
                context.go('/');
              },
            ),
          // Always display FAQ icon
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: t.faq.tooltip,
            onPressed: () {
              kIsWeb ? context.go(FaqScreen.routeName) : context.push(FaqScreen.routeName);
            },
          ),
        ],
      ),
      body: _buildBody(widget.body),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(),

            if (kIsWeb || !Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse('https://github.com/bitblik/client/releases');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not open APK link.'),
                              ), // This can remain hardcoded or be added to Slang if needed
                            );
                          }
                        }
                      },
                      child: Image.asset('assets/apk.png', width: 100, height: 31, fit: BoxFit.contain),
                      //  Icon(Icons.android, size: 32, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse('zapstore://app.bitblik');
                        await launchUrl(url);
                      },
                      child: Image.asset('assets/zapstore.png', width: 100, height: 31, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            publicKeyAsync.when(
              data: (publicKey) =>
              publicKey != null
                  ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showNekoInfoDialog(publicKey),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text(t.neko.yourNeko, style: Theme.of(context).textTheme.bodySmall),
                      // const SizedBox(width: 4),
                      CachedNetworkImage(
                        imageUrl: 'https://robohash.org/$publicKey?set=set4',
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${Nip19.encodePubKey(publicKey).substring(0, 21)}...',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.backup),
                        tooltip: t.backup.tooltips.backup,
                        onPressed: _showBackupDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.restore),
                        tooltip: t.restore.tooltips.restore,
                        onPressed: _showRestoreDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: t.generateNewKey.tooltips.generate,
                        onPressed: _showGenerateNewKeyDialog,
                      ),
                    ],
                  ),
                ),
              )
                  : const SizedBox.shrink(),
              loading: () =>
              const Center(
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (err, stack) =>
                  Text(
                    'Error loading key: $err', // This can remain hardcoded or be added to Slang if needed
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
            ),
            // Consumer(
            //   builder: (context, ref, _) {
            //     final lightningAddressAsync = ref.watch(lightningAddressProvider);
            //     return lightningAddressAsync.when(
            //       data:
            //           (address) =>
            //               address != null && address.isNotEmpty
            //                   ? Padding(
            //                     padding: const EdgeInsets.only(top: 4.0),
            //                     child: SelectableText(
            //                       t.lightningAddress.labels.short(address: address), // Use Slang
            //                       style: Theme.of(context).textTheme.bodySmall,
            //                       textAlign: TextAlign.center,
            //                     ),
            //                   )
            //                   : const SizedBox.shrink(),
            //       loading: () => const SizedBox.shrink(),
            //       error:
            //           (err, stack) => Padding(
            //             padding: const EdgeInsets.only(top: 4.0),
            //             child: Text(
            //               t.lightningAddress.errors.loading(details: err.toString()), // Use Slang
            //               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  // Body builder that handles both direct routes and role-based content
  Widget _buildBody(Widget directChild) {
    // If we're displaying a direct route's content, show that
    if (directChild is! RoleSelectionScreen) {
      return directChild;
    }

    // Otherwise, use the role-based logic for default screens
    // switch (role) {
    //   case AppRole.maker:
    //     return const MakerAmountForm();
    //   case AppRole.taker:
    //     final activeOffer = ref.watch(activeOfferProvider);
    //     if (activeOffer == null) {
    //       return const OfferListScreen();
    //     } else {
    //       if (activeOffer.status == OfferStatus.reserved.name) {
    //         return TakerSubmitBlikScreen(initialOffer: activeOffer);
    //       } else if (activeOffer.status == OfferStatus.blikReceived.name ||
    //           activeOffer.status == OfferStatus.blikSentToMaker.name ||
    //           activeOffer.status == OfferStatus.makerConfirmed.name) {
    //         return TakerWaitConfirmationScreen(offer: activeOffer);
    //       } else {
    //         print(
    //           "[AppScaffold] Taker role active but offer status (${activeOffer.status}) not suitable for flow screens. Showing OfferListScreen.",
    //         );
    //         return const OfferListScreen();
    //       }
    //     }
    //   case AppRole.none:
    //     return const RoleSelectionScreen();
    // }
    return const RoleSelectionScreen();
  }
}
