import 'dart:async';
import 'dart:io' show Platform; // Import Platform

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Keep for GlobalMaterialLocalizations.delegates
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/logger/logger.dart';
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
import 'src/utils/platform_detection.dart'; // Import our platform detection utility
import 'src/screens/coordinator_management_screen.dart';
import 'src/screens/settings_screen.dart';
import 'src/screens/neko_management_screen.dart';
import 'src/screens/wallet_screen.dart';

final double kMakerFeePercentage = 0.5;
final double kTakerFeePercentage = 0.5;
final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
late AppLocale appLocale;
final rustEventVerifier = RustEventVerifier();

/// Listen to connectivity changes and reconnect NDK when connectivity is restored
StreamSubscription<List<ConnectivityResult>> listenToConnectivityChanges(WidgetRef ref) {
  return Connectivity().onConnectivityChanged
      .skip(1) // do not fire on app startup
      .listen((List<ConnectivityResult> result) {
        if (result.any((e) => e == ConnectivityResult.none)) {
          return;
        }
        final ndkInstance = ref.read(ndkProvider);
        if (ndkInstance != null) {
          ndkInstance.connectivity.tryReconnect();
        }
      });
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // Determine page title and back button visibility from route
          String? pageTitle;
          bool hideBackButton = false;
          bool showBackButton = false;

          // Extract route-specific settings from state
          final path = state.uri.path;
          if (path == FaqScreen.routeName) {
            hideBackButton = true;
          }

          return AppScaffold(
            body: child,
            pageTitle: pageTitle,
            showBackButton: showBackButton,
            hideBackButton: hideBackButton,
          );
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const RoleSelectionScreen()),
          GoRoute(path: '/offers', builder: (context, state) => const OfferListScreen()),
          GoRoute(
            path: '/offers/:id',
            builder: (context, state) {
              final offerId = state.pathParameters['id'];
              if (offerId == null) {
                return const Center(child: Text('No offer ID provided.'));
              }
              return OfferDetailsScreen(offerId: offerId);
            },
          ),
          GoRoute(path: '/create', builder: (context, state) => const MakerAmountForm()),
          GoRoute(path: '/pay', builder: (context, state) => const MakerPayInvoiceScreen()),
          GoRoute(path: '/wait-taker', builder: (context, state) => const MakerWaitTakerScreen()),
          GoRoute(path: '/wait-blik', builder: (context, state) => const MakerWaitForBlikScreen()),
          GoRoute(path: '/confirm-blik', builder: (context, state) => const MakerConfirmPaymentScreen()),
          GoRoute(
            path: '/maker-success',
            builder: (context, state) {
              if (state.extra == null) {
                context.go("/");
                return Container();
              } else {
                return MakerSuccessScreen(completedOffer: state.extra as Offer);
              }
            },
          ),
          GoRoute(path: '/coordinators', builder: (context, state) => const CoordinatorManagementScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
          GoRoute(path: '/neko-management', builder: (context, state) => const NekoManagementScreen()),
          GoRoute(
            path: '/submit-blik',
            builder: (context, state) {
              if (state.extra == null) {
                context.go("/");
                return Container();
              } else {
                return TakerSubmitBlikScreen(initialOffer: state.extra as Offer);
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
                return TakerWaitConfirmationScreen(offer: state.extra as Offer);
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
                return TakerPaymentFailedScreen(offer: state.extra as Offer);
              }
            },
          ),
          GoRoute(path: '/paying-taker', builder: (context, state) => TakerPaymentProcessScreen()),
          GoRoute(
            path: '/taker-invalid-blik',
            builder: (context, state) {
              if (state.extra == null) {
                context.go("/");
                return Container();
              } else {
                return TakerInvalidBlikScreen(offer: state.extra as Offer);
              }
            },
          ),
          GoRoute(
            path: '/taker-conflict',
            builder: (context, state) => TakerConflictScreen(offerId: state.extra as String),
          ),
          GoRoute(
            path: '/maker-invalid-blik',
            builder: (context, state) {
              if (state.extra == null) {
                context.go("/");
                return Container();
              } else {
                return MakerInvalidBlikScreen(offer: state.extra as Offer);
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
                return MakerConflictScreen(offer: state.extra as Offer);
              }
            },
          ),
          GoRoute(path: FaqScreen.routeName, builder: (context, state) => const FaqScreen()),
        ],
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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    try {
      ref.read(keyServiceProvider);
      ref.read(apiServiceProvider);

      Logger.log.i('🚀 App initialized: API service and coordinator discovery started');
    } catch (e) {
      Logger.log.e('❌ Error during app initialization: $e');
    }

    // Initialize API service and start coordinator discovery
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(initializedApiServiceProvider.future);
        // Trigger coordinator discovery
        ref.watch(discoveredCoordinatorsProvider);

        // Initialize the offer status subscription manager
        ref.read(offerStatusSubscriptionManagerProvider);

        // Initialize app lifecycle provider (reconnects NDK when app resumes)
        ref.read(appLifecycleProvider);

        // Start listening to connectivity changes
        _connectivitySubscription = listenToConnectivityChanges(ref);

        Logger.log.i('🚀 App initialized: API service and coordinator discovery started');
      } catch (e) {
        Logger.log.e('❌ Error during app initialization: $e');
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
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final t = Translations.of(context);

    return MaterialApp.router(
      title: t.app.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
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
  final bool showBackButton; // Whether to show back button
  final bool hideBackButton; // Whether to explicitly hide back button

  const AppScaffold({
    super.key,
    required this.body,
    this.pageTitle,
    this.showBackButton = false,
    this.hideBackButton = false,
  });

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

  Widget _buildNekoDrawer(BuildContext context, AsyncValue<String?> publicKeyAsync) {
    final t = Translations.of(context);
    return Drawer(
      backgroundColor: Colors.white,
      child: publicKeyAsync.when(
        data: (publicKey) {
          if (publicKey == null) {
            return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No Neko found')));
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (kIsWeb) {
                          context.go(NekoManagementScreen.routeName);
                        } else {
                          context.push(NekoManagementScreen.routeName);
                        }
                      },
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        imageUrl: 'https://robohash.org/$publicKey?set=set4',
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (kIsWeb) {
                          context.go(NekoManagementScreen.routeName);
                        } else {
                          context.push(NekoManagementScreen.routeName);
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.nekoInfo.title, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            const Icon(Icons.info_outline, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.flash_on, color: Color(0xFFFF0000)),
                title: Text(t.landing.actions.payBlik),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  if (kIsWeb) {
                    context.go("/create");
                  } else {
                    context.push("/create");
                  }
                },
              ),
              ListTile(
                leading: Image.asset('assets/sell-blik.png', width: 24, height: 24),
                title: Text(t.landing.actions.sellBlik),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  if (kIsWeb) {
                    context.go("/offers");
                  } else {
                    context.push("/offers");
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(t.landing.actions.howItWorks),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  if (kIsWeb) {
                    context.go("/faq");
                  } else {
                    context.push("/faq");
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(t.settings.title),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  if (kIsWeb) {
                    context.go("/settings");
                  } else {
                    context.push("/settings");
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
        error:
            (error, stack) =>
                Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${error.toString()}'))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final publicKeyAsync = ref.watch(publicKeyProvider);

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
          child: Image.asset('assets/logo-horizontal.png', height: 30, fit: BoxFit.cover),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading:
            !widget.hideBackButton &&
            ((widget.pageTitle != null && widget.pageTitle!.isNotEmpty) || widget.showBackButton),
        // Show back button if pageTitle is present or showBackButton is true, unless hideBackButton is true
        title: appBarTitle,
        // Add a divider at the bottom of the AppBar
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1.0), child: Divider(height: 1.0, thickness: 1.0)),
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
                    child: Image.asset('assets/lang-switcher.png', width: 60, height: 60, fit: BoxFit.fitHeight),
                  );
                }).toList();
              },
              onChanged: (AppLocale? newLocale) async {
                if (newLocale != null) {
                  await asyncPrefs.setString('app_locale', newLocale.languageCode);
                  if (LocaleSettings.currentLocale.languageCode != newLocale.languageCode) {
                    appLocale = newLocale.languageCode == 'pl' ? AppLocale.pl : AppLocale.en;
                    LocaleSettings.setLocale(appLocale);
                    // Force rebuild to update UI
                    if (mounted) {
                      setState(() {});
                    }
                  }
                }
              },
              items:
                  AppLocale.values.map<DropdownMenuItem<AppLocale>>((AppLocale locale) {
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
                          Text(flagEmoji, style: const TextStyle(fontSize: 14)),
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
          // Neko icon - opens side menu
          publicKeyAsync.when(
            data:
                (publicKey) =>
                    publicKey != null
                        ? Builder(
                          builder:
                              (builderContext) => IconButton(
                                icon: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://robohash.org/$publicKey?set=set4',
                                    placeholder:
                                        (context, url) => const SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error, size: 24),
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                tooltip: t.nekoInfo.title,
                                onPressed: () {
                                  Scaffold.of(builderContext).openEndDrawer();
                                },
                              ),
                        )
                        : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          kDebugMode ? SizedBox(width: 40) : Container(),
        ],
      ),
      body: _buildBody(widget.body),
      endDrawer: _buildNekoDrawer(context, publicKeyAsync),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(),

            // Version, GitHub link, and download buttons on the same line
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Version and GitHub link on the left
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          // onTap: () async {
                          //   final Uri url = Uri.parse('https://github.com/bitblik-user/client/releases');
                          //   await launchUrl(url, mode: LaunchMode.externalApplication);
                          // },
                          child: Text(
                            _clientVersion != null ? 'v$_clientVersion' : '',
                            style: const TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 16),
                      // InkWell(
                      //   onTap: () async {
                      //     final Uri url = Uri.parse('https://github.com/bitblik-user/client');
                      //     await launchUrl(url, mode: LaunchMode.externalApplication);
                      //   },
                      //   child: Image.asset('assets/github.png', width: 20, height: 20),
                      // ),
                      // const SizedBox(width: 8),
                      InkWell(
                        onTap: () async {
                          final Uri url = Uri.parse(
                            'https://njump.to/npub1k3g092rlzvn7nftz3jte9pkx63zp705nh78r6hjpjm55fjg7r2cqx8stj3',
                          );
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                        child: Image.asset('assets/nostr.png', width: 32, height: 32),
                      ),
                    ],
                  ),
                  // Download buttons on the right (only when on web Android)
                  if (PlatformDetection.isWebAndroid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            final Uri url = Uri.parse('https://github.com/bitblik/client/releases');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Could not open APK link.')));
                              }
                            }
                          },
                          child: Image.asset('assets/apk.png', width: 100, height: 31, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () async {
                            final Uri url = Uri.parse('zapstore://app.bitblik');
                            await launchUrl(url);
                          },
                          child: Image.asset('assets/zapstore.png', width: 100, height: 31, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                ],
              ),
            ),
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
