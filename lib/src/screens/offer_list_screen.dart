import 'dart:async'; // Import async for Timer

import 'package:bitblik/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/coordinator_info.dart'; // Added
// import 'taker_flow_screen.dart'; // No longer needed directly
import '../models/offer.dart'; // Import Offer model
import '../providers/providers.dart';
import '../utils/ln.dart';
import '../widgets/progress_indicators.dart'; // Import the progress indicators
import 'taker_flow/taker_submit_blik_screen.dart'; // Import new screen
import 'taker_flow/taker_wait_confirmation_screen.dart'; // Import new screen

// --- OfferListScreen ---

class OfferListScreen extends ConsumerStatefulWidget {
  const OfferListScreen({super.key});

  @override
  ConsumerState<OfferListScreen> createState() => _OfferListScreenState();
}

class _OfferListScreenState extends ConsumerState<OfferListScreen> {
  Timer? _refreshTimer;

  bool _timerActive = false;
  bool _requestedFocus = false;
  String? _validationError;
  bool _hasValidatedInitialAddress = false;
  bool _isValidating = false;

  // Persistent controller and form key for lightning address input
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

  // For Coordinator Config
  CoordinatorInfo? _coordinatorInfo;
  Duration? _reservationDuration;
  bool _isLoadingCoordinatorConfig = true;
  String? _coordinatorConfigError;

  @override
  void initState() {
    super.initState();
    _hasValidatedInitialAddress = false;
    _isValidating = false;
    _loadCoordinatorConfig();
  }

  Future<void> _loadCoordinatorConfig() async {
    if (!mounted) return;
    // Ensure context is available for AppLocalizations early if needed for error messages
    // It might be safer to get strings inside the try/catch or pass it if needed for error messages
    // For now, assuming AppLocalizations.of(context) will be valid when setState is called.
    setState(() {
      _isLoadingCoordinatorConfig = true;
      _coordinatorConfigError = null;
    });
    try {
      final apiService = ref.read(apiServiceProvider);
      final coordinatorInfo = await apiService.getCoordinatorInfo();
      if (!mounted) return;

      setState(() {
        _coordinatorInfo = coordinatorInfo;
        _reservationDuration = Duration(
          seconds: coordinatorInfo.reservationSeconds,
        );
        _isLoadingCoordinatorConfig = false;
      });
    } catch (e) {
      if (!mounted) return;
      print(
        "[OfferListScreen] Error loading coordinator info: ${e.toString()}",
      );
      // It's good practice to ensure context is still valid if using AppLocalizations here.
      // For simplicity, we'll assume it is, or use a generic error string.
      final strings = AppLocalizations.of(context);
      setState(() {
        _isLoadingCoordinatorConfig = false;
        _coordinatorConfigError =
            strings?.errorLoadingCoordinatorConfig ?? "Error loading config";
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _startRefreshTimer() {
    if (_timerActive) return;
    _timerActive = true;
    _refreshTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(availableOffersProvider);
        ref.invalidate(initialActiveOfferProvider);
      }
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        print("[OfferListScreen] Periodic refresh.");
        ref.invalidate(availableOffersProvider);
        ref.invalidate(initialActiveOfferProvider);
      } else {
        timer.cancel();
      }
    });
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _timerActive = false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!; // Get strings instance
    final lightningAddressAsync = ref.watch(lightningAddressProvider);
    final keyService = ref.read(keyServiceProvider);

    final offersAsyncValue = ref.watch(availableOffersProvider);
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);
    final myActiveOfferAsyncValue = ref.watch(initialActiveOfferProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: lightningAddressAsync.when(
        loading: () {
          _stopRefreshTimer();
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, s) {
          _stopRefreshTimer();
          // Use localized string with placeholder
          return Center(
            child: Text(strings.errorLoadingLightningAddress(e.toString())),
          );
        },
        data: (lightningAddress) {
          // Perform one-time validation when address is loaded
          if (!_hasValidatedInitialAddress &&
              lightningAddress != null &&
              lightningAddress.isNotEmpty) {
            _hasValidatedInitialAddress = true;
            setState(() {
              _isValidating = true;
            });
            validateLightningAddress(
              lightningAddress,
              AppLocalizations.of(context)!,
            ).then((error) {
              if (mounted) {
                setState(() {
                  _validationError = error;
                  _isValidating = false;
                });
              }
            });
          }

          if (lightningAddress == null || lightningAddress.isEmpty) {
            _stopRefreshTimer();

            // Only request focus the first time after widget is mounted and input is shown
            if (_requestedFocus && _addressFocusNode.hasFocus) {
              // do nothing, already focused
            } else if (!_requestedFocus) {
              _requestedFocus = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_addressFocusNode.hasFocus) {
                  _addressFocusNode.requestFocus();
                }
              });
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.enterLightningAddress,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _addressFormKey,
                    child: TextFormField(
                      controller: _addressController,
                      focusNode: _addressFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.lightningAddressHint,
                        labelText:
                            AppLocalizations.of(context)!.lightningAddressLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return AppLocalizations.of(
                            context,
                          )!.lightningAddressInvalid;
                        }
                        return _validationError;
                      },
                      onChanged: (value) async {
                        if (value.isNotEmpty && value.contains('@')) {
                          final error = await validateLightningAddress(
                            value,
                            AppLocalizations.of(context)!,
                          );
                          if (mounted) {
                            setState(() {
                              _validationError = error;
                            });
                          }
                        } else {
                          setState(() {
                            _validationError = null;
                          });
                        }
                      },
                      onFieldSubmitted: (value) async {
                        if (_addressFormKey.currentState!.validate() &&
                            _validationError == null) {
                          try {
                            await keyService.saveLightningAddress(
                              _addressController.text,
                            );
                            ref.invalidate(lightningAddressProvider);
                            // Use localized string
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.lightningAddressSaved,
                                ),
                              ),
                            );
                          } catch (e) {
                            // Use localized string with placeholder
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.errorSavingAddress(e.toString()),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_addressFormKey.currentState!.validate() &&
                          _validationError == null) {
                        try {
                          await keyService.saveLightningAddress(
                            _addressController.text,
                          );
                          ref.invalidate(lightningAddressProvider);
                          // Use localized string
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.lightningAddressSaved,
                              ),
                            ),
                          );
                        } catch (e) {
                          // Use localized string with placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.errorSavingAddress(e.toString()),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.saveAndContinue),
                  ),
                ],
              ),
            );
          }

          // Lightning address exists, show offers list as before
          // Reset focus flag so that if user logs out and comes back, focus will be requested again
          _requestedFocus = false;
          _startRefreshTimer();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isValidating)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_validationError == null &&
                        _hasValidatedInitialAddress)
                      // Use localized string for tooltip
                      Tooltip(
                        message: strings.validLightningAddressTooltip,
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      )
                    else if (_validationError != null)
                      Tooltip(
                        message: _validationError!,
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        lightningAddress,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      // Use localized string
                      tooltip:
                          AppLocalizations.of(context)!.editLightningAddress,
                      onPressed: () async {
                        final editController = TextEditingController(
                          text: lightningAddress,
                        );
                        final editFormKey = GlobalKey<FormState>();
                        final editFocusNode = FocusNode();
                        String? editValidationError;

                        final result = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            // Request focus when the dialog is shown
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              editFocusNode.requestFocus();
                            });
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  // Use localized string
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.editLightningAddress,
                                  ),
                                  content: Form(
                                    key: editFormKey,
                                    child: TextFormField(
                                      controller: editController,
                                      focusNode: editFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      // Use localized strings
                                      decoration: InputDecoration(
                                        hintText:
                                            AppLocalizations.of(
                                              context,
                                            )!.lightningAddressHint,
                                        labelText:
                                            AppLocalizations.of(
                                              context,
                                            )!.lightningAddressLabel,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !value.contains('@')) {
                                          // Use localized string
                                          return AppLocalizations.of(
                                            context,
                                          )!.lightningAddressInvalid;
                                        }
                                        return editValidationError;
                                      },
                                      onChanged: (value) async {
                                        if (value.isNotEmpty &&
                                            value.contains('@')) {
                                          final error =
                                              await validateLightningAddress(
                                                value,
                                                AppLocalizations.of(context)!,
                                              );
                                          setState(() {
                                            editValidationError = error;
                                          });
                                        } else {
                                          setState(() {
                                            editValidationError = null;
                                          });
                                        }
                                      },
                                      onFieldSubmitted: (value) async {
                                        if (editFormKey.currentState!
                                                .validate() &&
                                            editValidationError == null) {
                                          try {
                                            await keyService
                                                .saveLightningAddress(
                                                  editController.text,
                                                );
                                            ref.invalidate(
                                              lightningAddressProvider,
                                            );
                                            Navigator.of(
                                              context,
                                            ).pop(editController.text);
                                            // Use localized string
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.lightningAddressUpdated,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            // Use localized string with placeholder
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.errorSavingAddress(
                                                    e.toString(),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      // Use localized string
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (editFormKey.currentState!
                                                .validate() &&
                                            editValidationError == null) {
                                          try {
                                            await keyService
                                                .saveLightningAddress(
                                                  editController.text,
                                                );
                                            ref.invalidate(
                                              lightningAddressProvider,
                                            );
                                            Navigator.of(
                                              context,
                                            ).pop(editController.text);
                                            // Use localized string
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.lightningAddressUpdated,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            // Use localized string with placeholder
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.errorSavingAddress(
                                                    e.toString(),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      // Use localized string
                                      child: Text(
                                        AppLocalizations.of(context)!.save,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                        if (result != null && result != lightningAddress) {
                          ref.invalidate(lightningAddressProvider);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Center(
                child: InkWell(
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://simplex.chat/contact#/?v=2-7&smp=smp%3A%2F%2Fu2dS9sG8nMNURyZwqASV4yROM28Er0luVTx5X1CsMrU%3D%40smp4.simplex.im%2FjwS8YtivATVUtHogkN2QdhVkw2H6XmfX%23%2F%3Fv%3D1-3%26dh%3DMCowBQYDK2VuAyEAsNpGcPiALZKbKfIXTQdJAuFxOmvsuuxMLR9rwMIBUWY%253D%26srv%3Do5vmywmrnaxalvz6wi3zicyftgio6psuvyniis6gco6bp6ekl4cqj4id.onion&data=%7B%22groupLinkId%22%3A%22hCkt5Ph057tSeJdyEI0uug%3D%3D%22%7D',
                    );
                    // if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                    // }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align items to the top
                    children: [
                      Image.asset('assets/simplex.png', height: 24, width: 24),
                      const SizedBox(width: 8),
                      // Use localized string
                      Flexible(
                        // Wrap with Flexible
                        child: Text(
                          AppLocalizations.of(context)!.getNotifiedSimplex,
                          textAlign: TextAlign.center, // Center align text
                          style: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.primary, // Use theme color
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Add some spacing
              Center(
                child: InkWell(
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://matrix.to/#/#bitblik-offers:matrix.org',
                    );
                    // if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                    // }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align items to the top
                    children: [
                      Image.asset('assets/element.png', height: 24, width: 24),
                      const SizedBox(width: 8),
                      // Use localized string
                      Flexible(
                        // Wrap with Flexible
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.getNotifiedWithElement, // Use l10n key
                          textAlign: TextAlign.center, // Center align text
                          style: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.primary, // Use theme color
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Add some spacing
              // const SizedBox(
              //   height: 16,
              // ), // Add some spacing before active offers // Removed, Divider provides spacing
              Expanded(
                child: offersAsyncValue.when(
                  data: (offers) {
                    if (offers.isEmpty) {
                      // Use localized string
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.noOffersAvailable,
                        ),
                      );
                    }
                    // Separate finished offers
                    final finishedStatuses = [
                      OfferStatus.settled.name,
                      OfferStatus.takerPaid.name,
                      OfferStatus.expired.name,
                      OfferStatus.cancelled.name,
                    ];
                    final finishedOffers =
                        offers
                            .where(
                              (offer) =>
                                  finishedStatuses.contains(offer.status),
                            )
                            .toList();
                    final activeOffers =
                        offers
                            .where(
                              (offer) =>
                                  !finishedStatuses.contains(offer.status),
                            )
                            .toList();

                    // If there are no active offers but there are finished offers,
                    // we might not want to expand the ListView for active offers.
                    // The main column will handle scrolling if stats + finished offers exceed screen height.
                    final bool showActiveOffersList = activeOffers.isNotEmpty;

                    return Column(
                      children: [
                        // Active offers
                        if (showActiveOffersList)
                          Expanded(
                            // Only expand if there are active offers to show
                            child: RefreshIndicator(
                              onRefresh: () async {
                                print(
                                  "[OfferListScreen] Manual refresh triggered.",
                                );
                                ref.invalidate(availableOffersProvider);
                                ref.invalidate(initialActiveOfferProvider);
                                await ref.read(availableOffersProvider.future);
                              },
                              child: ListView.builder(
                                itemCount: activeOffers.length,
                                itemBuilder: (context, index) {
                                  final offer = activeOffers[index];
                                  final bool isFunded =
                                      offer.status == OfferStatus.funded.name;
                                  final bool isReserved =
                                      offer.status == OfferStatus.reserved.name;
                                  final bool isBlikReceived =
                                      offer.status ==
                                      OfferStatus.blikReceived.name;

                                  Widget? trailingWidget;

                                  if (isFunded) {
                                    trailingWidget = ElevatedButton(
                                      onPressed: publicKeyAsyncValue.maybeWhen(
                                        data:
                                            (publicKey) => () async {
                                              if (publicKey == null) {
                                                return; // Still need pubkey
                                              }

                                              final takerId = publicKey;
                                              final apiService = ref.read(
                                                apiServiceProvider,
                                              );
                                              final scaffoldMessenger =
                                                  ScaffoldMessenger.of(context);

                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (context) => const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                              );
                                              try {
                                                final DateTime?
                                                reservationTimestamp =
                                                    await apiService
                                                        .reserveOffer(
                                                          offer.id,
                                                          takerId,
                                                        );

                                                if (reservationTimestamp !=
                                                    null) {
                                                  final Offer
                                                  updatedOffer = Offer(
                                                    id: offer.id,
                                                    amountSats:
                                                        offer.amountSats,
                                                    takerFees: offer.takerFees,
                                                    makerFees: offer.makerFees,
                                                    // Renamed
                                                    fiatCurrency:
                                                        offer.fiatCurrency,
                                                    fiatAmount:
                                                        offer.fiatAmount,
                                                    status:
                                                        OfferStatus
                                                            .reserved
                                                            .name,
                                                    createdAt: offer.createdAt,
                                                    makerPubkey:
                                                        offer.makerPubkey,
                                                    takerPubkey: takerId,
                                                    reservedAt:
                                                        reservationTimestamp,
                                                    blikReceivedAt:
                                                        offer.blikReceivedAt,
                                                    blikCode: offer.blikCode,
                                                    holdInvoicePaymentHash:
                                                        offer
                                                            .holdInvoicePaymentHash,
                                                  );

                                                  ref
                                                      .read(
                                                        activeOfferProvider
                                                            .notifier,
                                                      )
                                                      .state = updatedOffer;
                                                  ref
                                                      .read(
                                                        appRoleProvider
                                                            .notifier,
                                                      )
                                                      .state = AppRole.taker;

                                                  context.go(
                                                    "/submit-blik",
                                                    extra: updatedOffer,
                                                  );
                                                } else {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(); // Pop loading
                                                  // Use localized string
                                                  ref
                                                      .read(
                                                        errorProvider.notifier,
                                                      )
                                                      .state = strings
                                                          .errorFailedToReserveOfferNoTimestamp;
                                                  if (scaffoldMessenger
                                                      .mounted) {
                                                    scaffoldMessenger.showSnackBar(
                                                      SnackBar(
                                                        // Use localized string
                                                        content: Text(
                                                          strings
                                                              .errorFailedToReserveOfferNoTimestamp,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  ref.invalidate(
                                                    availableOffersProvider,
                                                  );
                                                }
                                              } catch (e) {
                                                if (Navigator.of(
                                                  context,
                                                ).canPop()) {
                                                  Navigator.of(context).pop();
                                                }
                                                // Use localized string with placeholder
                                                final errorMsg = strings
                                                    .errorFailedToReserveOffer(
                                                      e.toString(),
                                                    );
                                                ref
                                                    .read(
                                                      errorProvider.notifier,
                                                    )
                                                    .state = errorMsg;
                                                if (scaffoldMessenger.mounted) {
                                                  scaffoldMessenger.showSnackBar(
                                                    SnackBar(
                                                      // Use localized string
                                                      content: Text(errorMsg),
                                                    ),
                                                  );
                                                }
                                                ref.invalidate(
                                                  availableOffersProvider,
                                                );
                                              }
                                            },
                                        orElse:
                                            () =>
                                                null, // Disable if public key loading/error
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.take,
                                      ),
                                    );
                                  } else if (isReserved || isBlikReceived) {
                                    trailingWidget = myActiveOfferAsyncValue.when(
                                      data: (myOffer) {
                                        if (myOffer != null &&
                                            offer.id == myOffer.id) {
                                          return ElevatedButton(
                                            // Use localized string
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.resume,
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    activeOfferProvider
                                                        .notifier,
                                                  )
                                                  .state = myOffer;
                                              ref
                                                  .read(
                                                    appRoleProvider.notifier,
                                                  )
                                                  .state = AppRole.taker;

                                              // Determine which screen to navigate to based on status
                                              Widget destinationScreen;
                                              if (myOffer.status ==
                                                  OfferStatus.reserved.name) {
                                                destinationScreen =
                                                    TakerSubmitBlikScreen(
                                                      initialOffer: myOffer,
                                                    ); // Pass offer
                                              } else if (myOffer.status ==
                                                      OfferStatus
                                                          .blikReceived
                                                          .name ||
                                                  myOffer.status ==
                                                      OfferStatus
                                                          .blikSentToMaker
                                                          .name ||
                                                  myOffer.status ==
                                                      OfferStatus
                                                          .makerConfirmed
                                                          .name) {
                                                destinationScreen =
                                                    TakerWaitConfirmationScreen(
                                                      offer: myOffer,
                                                    ); // Pass offer
                                              } else {
                                                print(
                                                  "[OfferListScreen] Error: Resuming offer in unexpected state: ${myOffer.status}",
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  // Use localized string
                                                  SnackBar(
                                                    content: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.errorOfferUnexpectedState,
                                                    ),
                                                  ),
                                                );
                                                return; // Don't navigate
                                              }

                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          destinationScreen,
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          return Text(
                                            offer.status.toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }
                                      },
                                      loading:
                                          () => const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      error: (e, s) {
                                        print(
                                          "Error loading myActiveOffer: $e",
                                        );
                                        return Text(
                                          offer.status.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    trailingWidget = Text(
                                      offer.status.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }

                                  trailingWidget ??= const SizedBox.shrink();

                                  return Column(
                                    children: [
                                      Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 5.0,
                                        ),
                                        child: ListTile(
                                          // Use localized strings with placeholders
                                          title: Text(
                                            // Assuming PLN for now, might need dynamic currency later
                                            '${formatDouble(offer.fiatAmount)} ${offer.fiatCurrency}',
                                          ),
                                          subtitle: Text(
                                            // Combine amount, fee, status, and ID using localized strings
                                            '${AppLocalizations.of(context)!.offerAmountSats(offer.amountSats.toString())}\n${AppLocalizations.of(context)!.offerFeeStatusId(offer.takerFees?.toString() ?? "0", offer.status)}',
                                          ),
                                          isThreeLine: true,
                                          trailing: trailingWidget,
                                        ),
                                      ),
                                      if (isFunded)
                                        FundedOfferProgressIndicator(
                                          key: ValueKey(
                                            'progress_funded_${offer.id}',
                                          ),
                                          createdAt: offer.createdAt,
                                        ),
                                      if (isReserved &&
                                          offer.reservedAt != null)
                                        ReservationProgressIndicator(
                                          key: ValueKey(
                                            'progress_res_${offer.id}_${_reservationDuration!.inSeconds}',
                                          ),
                                          reservedAt: offer.reservedAt!,
                                          maxDuration:
                                              _reservationDuration!, // Pass the dynamic duration
                                        ),
                                      if (isBlikReceived &&
                                          offer.blikReceivedAt != null)
                                        BlikConfirmationProgressIndicator(
                                          key: ValueKey(
                                            'progress_blik_${offer.id}',
                                          ),
                                          blikReceivedAt: offer.blikReceivedAt!,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        // Finished offers section - this might need adjustment if active offers list is not expanded
                        if (finishedOffers.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              top: showActiveOffersList ? 16.0 : 0,
                            ), // Adjust padding based on active offers
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Use localized string
                                Text(
                                  AppLocalizations.of(context)!.finishedOffers,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 200,
                                  // Consider making this flexible or removing fixed height
                                  child: Scrollbar(
                                    child: ListView.builder(
                                      shrinkWrap: !showActiveOffersList,
                                      // Shrink wrap if it's the only list
                                      physics:
                                          !showActiveOffersList
                                              ? const NeverScrollableScrollPhysics()
                                              : null,
                                      itemCount: finishedOffers.length,
                                      itemBuilder: (context, index) {
                                        final offer = finishedOffers[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5.0,
                                          ),
                                          child: ListTile(
                                            // Use localized string with placeholder
                                            title: Text(
                                              // Use the existing fiat amount display logic
                                              '${formatDouble(offer.fiatAmount)} ${offer.fiatCurrency}',
                                            ),
                                            // Use localized string with placeholders
                                            subtitle: Text(
                                              // Combine amount, fee, status, and ID using localized strings
                                              '${AppLocalizations.of(context)!.offerAmountSats(offer.amountSats.toString())}\n${AppLocalizations.of(context)!.offerFeeStatusId(offer.takerFees?.toString() ?? "0", offer.status)}',
                                            ),
                                            isThreeLine: true,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Use localized string with placeholder
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.errorLoadingOffers(error.toString()),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed:
                                  () => ref.invalidate(availableOffersProvider),
                              // Use localized string
                              child: Text(AppLocalizations.of(context)!.retry),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
              const Divider(height: 32, thickness: 1),
              // Separator
              // Add the Stats Section here
              _buildStatsSection(
                context,
                strings,
                ref.watch(successfulOffersStatsProvider),
              ),
            ],
          );
        },
      ),
    );
  }
}

String formatDouble(double value) {
  // Check if the value is effectively a whole number
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    // Format with up to 2 decimal places, removing trailing zeros
    String asString = value.toStringAsFixed(2);
    // Remove trailing zeros after decimal point
    if (asString.contains('.')) {
      asString = asString.replaceAll(RegExp(r'0+$'), '');
      // Remove decimal point if it's the last character
      if (asString.endsWith('.')) {
        asString = asString.substring(0, asString.length - 1);
      }
    }
    return asString;
  }
}

String _formatDurationFromSeconds(int? totalSeconds) {
  if (totalSeconds == null || totalSeconds < 0) {
    return '-';
  }
  if (totalSeconds == 0) {
    return '0s';
  }
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = totalSeconds % 60;

  String result = '';
  if (minutes > 0) {
    result += '${minutes}m ';
  }
  if (seconds > 0 || minutes == 0) {
    // Show seconds if non-zero, or if minutes is zero (e.g. "0s")
    result += '${seconds}s';
  }
  return result.trim();
}

Widget _buildStatsSection(
  BuildContext context,
  AppLocalizations strings,
  AsyncValue<Map<String, dynamic>> statsAsyncValue,
) {
  return statsAsyncValue.when(
    data: (data) {
      // Changed 'stats' to 'data' to match provider's direct output
      // Accessing nested stats structure
      final statsMap = data['stats'] as Map<String, dynamic>? ?? {};
      final lifetime = statsMap['lifetime'] as Map<String, dynamic>? ?? {};
      final last7Days = statsMap['last_7_days'] as Map<String, dynamic>? ?? {};

      // Accessing offers list directly from data
      final recentOffersData = data['offers'] as List<dynamic>? ?? [];
      // Ensure Offer.fromJson is robust or data matches client Offer model exactly
      // The ApiService already maps this to List<Offer>
      final recentOffers = recentOffersData.cast<Offer>();

      final numberFormat = NumberFormat("#,##0", strings.localeName);
      final dateFormat = DateFormat.yMd(strings.localeName).add_Hm();

      // Helper for succinct stat line
      String formatStatLine(
        String title,
        int? count,
        num? avgBlik,
        num? avgPaid,
      ) {
        final countStr = numberFormat.format(count ?? 0);
        final blikStr = avgBlik?.round().toString() ?? '-';
        final paidStr = avgPaid?.round().toString() ?? '-';
        // Using existing localization keys for "trades", "BLIK", "Paid" for now.
        // Ideally, create a new very compact key like "statsCompactLine": "{title}: {count} trades, BLIK {blikTime}s, Paid {paidTime}s"
        return '$title: $countStr trades, BLIK: ${blikStr}s, Paid: ${paidStr}s';
      }

      final lifetimeBlikTime =
          lifetime['avg_time_blik_received_to_created_seconds'] as num?;
      final lifetimePaidTime =
          lifetime['avg_time_taker_paid_to_created_seconds'] as num?;
      final last7DaysBlikTime =
          last7Days['avg_time_blik_received_to_created_seconds'] as num?;
      final last7DaysPaidTime =
          last7Days['avg_time_taker_paid_to_created_seconds'] as num?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.successfulTradeStatistics, // Existing title
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   // Using a placeholder for a new compact localization string
                //   strings.statsLifetimeCompact(
                //     numberFormat.format(lifetime['count'] ?? 0),
                //     lifetimeBlikTime?.round().toString() ?? '-',
                //     lifetimePaidTime?.round().toString() ?? '-',
                //   ),
                //   style: const TextStyle(fontSize: 13),
                // ),
                Text(
                  // Using a placeholder for a new compact localization string
                  strings.statsLast7DaysCompact(
                    numberFormat.format(last7Days['count'] ?? 0),
                    _formatDurationFromSeconds(last7DaysBlikTime!.toInt()),
                    _formatDurationFromSeconds(last7DaysPaidTime!.toInt()),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                if (recentOffers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(strings.noSuccessfulTradesYet),
                  )
                else
                  SizedBox(
                    height: 150, // Fixed height for scrollable list
                    child: Scrollbar(
                      // Added Scrollbar
                      child: ListView.builder(
                        shrinkWrap: true,
                        // Important for ListView inside SizedBox
                        physics: const AlwaysScrollableScrollPhysics(),
                        // Ensure it's scrollable
                        itemCount: recentOffers.length,
                        itemBuilder: (context, index) {
                          final offer = recentOffers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.offerFiatAmount(
                                      formatDouble(offer.fiatAmount),
                                      offer.fiatCurrency,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    strings.offerCreatedAt(
                                      dateFormat.format(
                                        offer.createdAt.toLocal(),
                                      ), // Named arg
                                    ),
                                  ),
                                  if (offer.timeToReserveSeconds != null)
                                    Text(
                                      strings.offerTakenAfter(
                                        _formatDurationFromSeconds(
                                          offer.timeToReserveSeconds,
                                        ), // Named arg
                                      ),
                                    ),
                                  if (offer.totalCompletionTimeTakerSeconds != null)
                                    Text(
                                      strings.offerPaidAfter(
                                        _formatDurationFromSeconds(
                                          offer.totalCompletionTimeTakerSeconds,
                                        ), // Named arg
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ), // End of ListView.builder
                  ), // End of Scrollbar
              ],
            ),
          ),
        ],
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error:
        (error, stackTrace) =>
            Center(child: Text(strings.errorLoadingStats(error.toString()))),
  );
}
