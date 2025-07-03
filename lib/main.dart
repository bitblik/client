import 'dart:async';
import 'package:bitblik/src/screens/maker_flow/maker_confirm_payment_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_invalid_blik_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_pay_invoice_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_success_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_wait_for_blik_screen.dart';
import 'package:bitblik/src/screens/maker_flow/maker_wait_taker_screen.dart';
import 'package:bitblik/src/screens/taker_flow/taker_invalid_blik_screen.dart';
import 'package:bitblik/src/screens/taker_flow/taker_payment_failed_screen.dart';
import 'package:bitblik/src/screens/taker_flow/taker_payment_process_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'dart:io' show Platform; // Import Platform
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'i18n/gen/strings.g.dart'; // Import Slang from new path
import 'src/providers/providers.dart';
import 'src/providers/locale_provider.dart'; // Import locale provider
import 'src/screens/role_selection_screen.dart';
import 'src/screens/maker_flow/maker_amount_form.dart';
import 'src/screens/offer_list_screen.dart';
import 'src/models/offer.dart'; // Needed for OfferStatus enum
import 'src/screens/taker_flow/taker_submit_blik_screen.dart';
import 'src/screens/taker_flow/taker_wait_confirmation_screen.dart';
import 'src/screens/taker_flow/taker_expired_sent_blik_screen.dart'; // Import the new screen
import 'src/screens/taker_flow/taker_conflict_screen.dart'; // Import the taker conflict screen
import 'src/screens/maker_flow/maker_conflict_screen.dart'; // Import the maker conflict screen
import 'src/screens/faq_screen.dart'; // Import the FAQ screen
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Keep for GlobalMaterialLocalizations.delegates

final double kMakerFeePercentage = 0.5;
final double kTakerFeePercentage = 0.5;

// Create a GoRouter provider for navigation
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) => const AppScaffold(body: RoleSelectionScreen()),
      ),
      GoRoute(
        path: '/offers',
        builder: (context, state) => const AppScaffold(body: OfferListScreen()),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const AppScaffold(body: MakerAmountForm()),
      ),
      GoRoute(
        path: '/pay',
        builder:
            (context, state) =>
                const AppScaffold(body: MakerPayInvoiceScreen()),
      ),
      GoRoute(
        path: '/wait-taker',
        builder:
            (context, state) => const AppScaffold(body: MakerWaitTakerScreen()),
      ),
      GoRoute(
        path: '/wait-blik',
        builder:
            (context, state) =>
                const AppScaffold(body: MakerWaitForBlikScreen()),
      ),
      GoRoute(
        path: '/confirm-blik',
        builder:
            (context, state) =>
                const AppScaffold(body: MakerConfirmPaymentScreen()),
      ),
      GoRoute(
        path: '/maker-success',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(
              body: MakerSuccessScreen(completedOffer: state.extra as Offer),
            );
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
            return AppScaffold(
              body: TakerSubmitBlikScreen(initialOffer: state.extra as Offer),
            );
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
            return AppScaffold(
              body: TakerWaitConfirmationScreen(offer: state.extra as Offer),
            );
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
            return AppScaffold(
              body: TakerPaymentFailedScreen(offer: state.extra as Offer),
            );
          }
        },
      ),
      GoRoute(
        path: '/paying-taker',
        builder:
            (context, state) => AppScaffold(body: TakerPaymentProcessScreen()),
      ),
      GoRoute(
        path: '/taker-invalid-blik',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(
              body: TakerInvalidBlikScreen(offer: state.extra as Offer),
            );
          }
        },
      ),

      GoRoute(
        path: '/taker-conflict',
        builder:
            (context, state) => AppScaffold(
              body: TakerConflictScreen(offerId: state.extra as String),
            ),
      ),
      GoRoute(
        path: '/maker-invalid-blik',
        builder: (context, state) {
          if (state.extra == null) {
            context.go("/");
            return Container();
          } else {
            return AppScaffold(
              body: MakerInvalidBlikScreen(offer: state.extra as Offer),
            );
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
            return AppScaffold(
              body: MakerConflictScreen(offer: state.extra as Offer),
            );
          }
        },
      ),
      GoRoute(
        path: FaqScreen.routeName,
        builder:
            (context, state) => AppScaffold(
              body: const FaqScreen(),
              pageTitle:
                  "FAQ", // Temporarily hardcoded. Add t.faq.screenTitle to Slang and use it here.
            ),
      ),
      GoRoute(
        path: '/taker-expired-blik',
        builder: (context, state) {
          if (state.extra == null) {
            // If no offer is passed, redirect to home or offer list
            // This prevents errors if the route is accessed directly without an offer
            context.go("/"); // Or '/offers'
            return Container(); // Return an empty container while redirecting
          } else {
            return AppScaffold(
              body: TakerExpiredSentBlikScreen(offer: state.extra as Offer),
            );
          }
        },
      ),
    ],
  );
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale(); // Initialize Slang with device locale
  runApp(
    TranslationProvider(
      // Wrap with TranslationProvider
      child: const ProviderScope(child: SafeArea(child: MyApp())),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider); // Watch the locale provider

    // Update Slang locale when provider changes
    if (locale != null &&
        LocaleSettings.currentLocale.languageCode != locale.languageCode) {
      final appLocale =
          locale.languageCode == 'pl' ? AppLocale.pl : AppLocale.en;
      LocaleSettings.setLocale(appLocale);
    }

    return MaterialApp.router(
      title: t.app.title, // Use Slang for title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: LocaleSettings.currentLocale.flutterLocale, // Use Slang locale
      supportedLocales:
          AppLocaleUtils.supportedLocales, // Use Slang supported locales
      localizationsDelegates:
          GlobalMaterialLocalizations.delegates, // Use Slang delegates
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
  Timer? _activeOfferRefreshTimer;
  String? _clientVersion;

  @override
  void initState() {
    super.initState();
    _startActiveOfferRefreshTimer();
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
    _activeOfferRefreshTimer?.cancel();
    super.dispose();
  }

  void _startActiveOfferRefreshTimer() {
    _activeOfferRefreshTimer?.cancel();
    // Refresh immediately first time after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        print("[AppScaffold] Initial refresh of active offer.");
        ref.invalidate(initialActiveOfferProvider);
      }
    });
    // Then refresh periodically (e.g., every 1 seconds)
    _activeOfferRefreshTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      if (mounted) {
        // print("[AppScaffold] Periodic refresh of active offer.");
        ref.invalidate(initialActiveOfferProvider);
      } else {
        timer.cancel(); // Stop timer if widget is disposed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final publicKeyAsync = ref.watch(publicKeyProvider);
    final appRole = ref.watch(appRoleProvider); // This line needs to be active
    final String currentPath = GoRouterState.of(context).uri.toString();

    Widget appBarTitle;
    // bool canGoBack = GoRouter.of(context).canGoBack(); // Removed this line

    if (widget.pageTitle != null && widget.pageTitle!.isNotEmpty) {
      appBarTitle = Text(widget.pageTitle!);
    } else {
      appBarTitle = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // Reset relevant state providers
            ref.read(appRoleProvider.notifier).state = AppRole.none;
            ref.read(activeOfferProvider.notifier).state = null;
            ref.read(holdInvoiceProvider.notifier).state = null;
            ref.read(paymentHashProvider.notifier).state = null;
            ref.read(receivedBlikCodeProvider.notifier).state = null;
            ref.read(errorProvider.notifier).state = null;
            ref.read(isLoadingProvider.notifier).state = false;
            ref.invalidate(availableOffersProvider);
            ref.invalidate(initialActiveOfferProvider);
            context.go('/');
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.app.title),
              const SizedBox(width: 4),
              Text(
                _clientVersion != null ? 'alpha v$_clientVersion' : 'alpha',
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
            (widget.pageTitle != null &&
                widget
                    .pageTitle!
                    .isNotEmpty), // Show back button if pageTitle is present
        title: appBarTitle,
        actions: [
          // Language Switcher Dropdown
          Container(
            color: Color(
              0x00fef7ff,
            ), // Consider Theme.of(context).appBarTheme.backgroundColor or similar
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<AppLocale>(
              // Use AppLocale from Slang
              value: LocaleSettings.currentLocale, // Use Slang current locale
              icon: const Icon(Icons.language),
              underline: const SizedBox.shrink(),
              onChanged: (AppLocale? newLocale) {
                if (newLocale != null) {
                  LocaleSettings.setLocale(newLocale); // Set Slang locale
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(
                        newLocale.flutterLocale,
                      ); // Update Riverpod provider
                }
              },
              items:
                  AppLocale.values.map<DropdownMenuItem<AppLocale>>((
                    AppLocale locale,
                  ) {
                    final String flagEmoji =
                        locale.languageCode == 'en'
                            ? '🇬🇧 '
                            : locale.languageCode == 'pl'
                            ? '🇵🇱 '
                            : '';
                    final String displayName =
                        locale.languageCode == 'en'
                            ? 'English'
                            : locale.languageCode == 'pl'
                            ? 'Polski'
                            : locale.languageCode.toUpperCase();
                    return DropdownMenuItem<AppLocale>(
                      value: locale,
                      child: Text(flagEmoji + displayName),
                    );
                  }).toList(),
            ),
          ),
          // Conditionally display Home icon if not on the main screen ('/')
          if (currentPath != '/')
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: t.common.buttons.goHome, // Use Slang for tooltip
              onPressed: () {
                // Reset relevant state providers
                ref.read(appRoleProvider.notifier).state = AppRole.none;
                ref.read(activeOfferProvider.notifier).state = null;
                ref.read(holdInvoiceProvider.notifier).state = null;
                ref.read(paymentHashProvider.notifier).state = null;
                ref.read(receivedBlikCodeProvider.notifier).state = null;
                ref.read(errorProvider.notifier).state = null;
                ref.read(isLoadingProvider.notifier).state = false;
                ref.invalidate(availableOffersProvider);
                ref.invalidate(initialActiveOfferProvider);

                // Navigate to home
                context.go('/');
              },
            ),
          // Always display FAQ icon
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'FAQ', // Consider localizing: t.common.buttons.faq
            onPressed: () {
              context.push(FaqScreen.routeName);
            },
          ),
        ],
      ),
      body: _buildBody(appRole, widget.body),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (kIsWeb || !Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://github.com/bitblik/client/releases',
                        );
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
                      child: Icon(Icons.android, size: 32, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse('zapstore://app.bitblik');
                        await launchUrl(url);
                      },
                      child: Image.asset(
                        'assets/zapstore.png',
                        width: 100,
                        height: 31,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            publicKeyAsync.when(
              data:
                  (publicKey) =>
                      publicKey != null
                          ? SelectableText(
                            'Your PubKey: $publicKey', // This can remain hardcoded or be added to Slang if needed
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          )
                          : const SizedBox.shrink(),
              loading:
                  () => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              error:
                  (err, stack) => Text(
                    'Error loading key: $err', // This can remain hardcoded or be added to Slang if needed
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final lightningAddressAsync = ref.watch(
                  lightningAddressProvider,
                );
                return lightningAddressAsync.when(
                  data:
                      (address) =>
                          address != null && address.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: SelectableText(
                                  t.lightningAddress.labels.short(
                                    address: address,
                                  ), // Use Slang
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              )
                              : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error:
                      (err, stack) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          t.lightningAddress.errors.loading(
                            details: err.toString(),
                          ), // Use Slang
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Body builder that handles both direct routes and role-based content
  Widget _buildBody(AppRole role, Widget directChild) {
    // If we're displaying a direct route's content, show that
    if (directChild is! RoleSelectionScreen) {
      return directChild;
    }

    // Otherwise, use the role-based logic for default screens
    switch (role) {
      case AppRole.maker:
        return const MakerAmountForm();
      case AppRole.taker:
        final activeOffer = ref.watch(activeOfferProvider);
        if (activeOffer == null) {
          return const OfferListScreen();
        } else {
          if (activeOffer.status == OfferStatus.reserved.name) {
            return TakerSubmitBlikScreen(initialOffer: activeOffer);
          } else if (activeOffer.status == OfferStatus.blikReceived.name ||
              activeOffer.status == OfferStatus.blikSentToMaker.name ||
              activeOffer.status == OfferStatus.makerConfirmed.name) {
            return TakerWaitConfirmationScreen(offer: activeOffer);
          } else {
            print(
              "[AppScaffold] Taker role active but offer status (${activeOffer.status}) not suitable for flow screens. Showing OfferListScreen.",
            );
            return const OfferListScreen();
          }
        }
      case AppRole.none:
        return const RoleSelectionScreen();
    }
  }
}
