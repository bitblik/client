import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/providers/providers.dart';
import 'src/screens/role_selection_screen.dart';
import 'src/screens/maker_flow/maker_amount_form.dart';
import 'src/screens/offer_list_screen.dart';
import 'src/models/offer.dart'; // Needed for OfferStatus enum
import 'src/screens/taker_flow/taker_submit_blik_screen.dart';
import 'src/screens/taker_flow/taker_wait_confirmation_screen.dart';

// Create a GoRouter provider for navigation
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
        path: '/pay',
        builder: (context, state) => const AppScaffold(body: MakerAmountForm()),
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

    return MaterialApp.router(
      title: 'BitBlika',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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

  @override
  void initState() {
    super.initState();
    _startActiveOfferRefreshTimer();
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('BitBlik'),
            const SizedBox(width: 4),
            Text(
              'alpha',
              style: TextStyle(fontSize: 10, color: Colors.black45)
              ),
          ],
        ),
        actions: [
          // Navigation button to offers
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Offers',
            onPressed: () => context.go('/offers'),
          ),
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
      bottomNavigationBar: publicKeyAsync.when(
        data:
            (publicKey) =>
                publicKey != null
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        'Your PubKey: $publicKey',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    )
                    : null,
        loading:
            () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        error:
            (err, stack) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error loading key: $err',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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
      default:
        return const RoleSelectionScreen();
    }
  }
}
