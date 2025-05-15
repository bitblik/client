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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'src/providers/providers.dart';
import 'src/providers/locale_provider.dart'; // Import locale provider
import 'src/screens/role_selection_screen.dart';
import 'src/screens/maker_flow/maker_amount_form.dart';
import 'src/screens/offer_list_screen.dart';
import 'src/models/offer.dart'; // Needed for OfferStatus enum
import 'src/screens/taker_flow/taker_submit_blik_screen.dart';
import 'src/screens/taker_flow/taker_wait_confirmation_screen.dart';
import 'src/screens/taker_flow/taker_conflict_screen.dart'; // Import the taker conflict screen
import 'src/screens/maker_flow/maker_conflict_screen.dart'; // Import the maker conflict screen
import 'package:package_info_plus/package_info_plus.dart';

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
        // routes: [,
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
        builder:
            (context, state) => AppScaffold(
              body: MakerSuccessScreen(completedOffer: state.extra as Offer),
            ),
      ),

      GoRoute(
        path: '/submit-blik',
        builder:
            (context, state) => AppScaffold(
              body: TakerSubmitBlikScreen(initialOffer: state.extra as Offer),
            ),
      ),
      GoRoute(
        path: '/wait-confirmation',
        builder:
            (context, state) => AppScaffold(
              body: TakerWaitConfirmationScreen(offer: state.extra as Offer),
            ),
      ),
      GoRoute(
        path: '/taker-failed',
        builder:
            (context, state) => AppScaffold(
              body: TakerPaymentFailedScreen(offer: state.extra as Offer),
            ),
      ),
      GoRoute(
        path: '/paying-taker',
        builder:
            (context, state) => AppScaffold(body: TakerPaymentProcessScreen()),
      ),
      GoRoute(
        path: '/taker-invalid-blik',
        builder:
            (context, state) => AppScaffold(
              body: TakerInvalidBlikScreen(offer: state.extra as Offer),
            ),
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
        builder:
            (context, state) => AppScaffold(
              body: MakerInvalidBlikScreen(offer: state.extra as Offer),
            ),
      ),
      GoRoute(
        path: '/maker-conflict',
        builder:
            (context, state) => AppScaffold(
              body: MakerConflictScreen(offer: state.extra as Offer),
            ),
      ),
    ],
  );
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SafeArea(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider); // Watch the locale provider

    return MaterialApp.router(
      title: 'BitBlik',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: locale,
      // Set locale from provider
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pl')],
      routerConfig: router,
    );
  }
}

// AppScaffold to maintain consistent UI structure with AppBar and footer
class AppScaffold extends ConsumerStatefulWidget {
  final Widget body;

  const AppScaffold({super.key, required this.body});

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
    _activeOfferRefreshTimer = Timer.periodic(const Duration(seconds: 1), (
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
    final appRole = ref.watch(appRoleProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: MouseRegion(
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

              // Navigate to home
              context.go('/');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('BitBlik'),
                const SizedBox(width: 4),
                Text(
                  _clientVersion != null ? 'alpha v$_clientVersion' : 'alpha',
                  style: TextStyle(fontSize: 10, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Language Switcher Dropdown
          // Wrap with Container for white background when closed
          Container(
            color: Color(0x00fef7ff),
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ), // Keep horizontal padding
            child: DropdownButton<Locale>(
              // Determine current value: provider state, or system locale if provider is null
              // Ensure the value exists in the items list. Default to 'en' if system/saved locale isn't supported.
              value:
                  AppLocalizations.supportedLocales.contains(
                        ref.watch(localeProvider),
                      )
                      ? ref.watch(localeProvider)
                      : (AppLocalizations.supportedLocales.contains(
                            Locale(
                              WidgetsBinding
                                  .instance
                                  .platformDispatcher
                                  .locale
                                  .languageCode,
                            ),
                          )
                          ? Locale(
                            WidgetsBinding
                                .instance
                                .platformDispatcher
                                .locale
                                .languageCode,
                          )
                          : const Locale('en')),
              // Fallback to 'en'
              icon: const Icon(Icons.language),
              underline: const SizedBox.shrink(),
              // Hide default underline
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).setLocale(newLocale);
                }
              },
              items:
                  AppLocalizations.supportedLocales
                      .map<DropdownMenuItem<Locale>>((Locale locale) {
                        // Simple display name logic
                        // Add flag emoji based on language code
                        final String flagEmoji =
                            locale.languageCode == 'en'
                                ? '🇬🇧 '
                                : locale.languageCode == 'pl'
                                ? '🇵🇱 '
                                : ''; // No emoji for other languages
                        final String displayName =
                            locale.languageCode == 'en'
                                ? 'English'
                                : locale.languageCode == 'pl'
                                ? 'Polski'
                                : locale.languageCode.toUpperCase();
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(flagEmoji + displayName), // Prepend emoji
                        );
                      })
                      .toList(),
            ),
          ),
          // // Navigation button to offers (commented out)
          // IconButton(
          //   icon: const Icon(Icons.list),
          //   tooltip: 'Offers',
          //   onPressed: () => context.go('/offers'),
          // ),
          // Reset button
          if (appRole != AppRole.none)
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Reset Role',
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
        ],
      ),
      body: _buildBody(appRole, widget.body),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (kIsWeb ||
                !Platform.isAndroid) // Show on web OR non-Android native
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open APK link.')),
                          );
                        }
                      },
                      child: Icon(
                        Icons.android,
                        size: 32, // Adjust size as needed
                        color: Colors.green, // Optional: for better visibility
                      ),
                    ),
                    const SizedBox(width: 16), // Spacing between icons
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
                            'Your PubKey: $publicKey',
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
                    'Error loading key: $err',
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
                                  'Your Lightning Address: $address',
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
                          'Error loading lightning address: $err',
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
