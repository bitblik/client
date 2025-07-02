import 'dart:async'; // Import async for Timer

import '../../i18n/gen/strings.g.dart'; // Import Slang
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/coordinator_info.dart'; // Added
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
      setState(() {
        _isLoadingCoordinatorConfig = false;
        _coordinatorConfigError = t.system.errors.loadingCoordinatorConfig;
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

          return Center(
            child: Text(
              t.lightningAddress.errors.loading(details: e.toString()),
            ),
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
            validateLightningAddress(lightningAddress, t).then((error) {
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
                    t.lightningAddress.prompts.enter,
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
                        hintText: t.lightningAddress.labels.hint,
                        labelText: t.lightningAddress.labels.address,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return t.lightningAddress.prompts.invalid;
                        }
                        return _validationError;
                      },
                      onChanged: (value) async {
                        if (value.isNotEmpty && value.contains('@')) {
                          final error = await validateLightningAddress(
                            value,
                            t,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t.lightningAddress.feedback.saved,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t.lightningAddress.errors.saving(
                                    details: e.toString(),
                                  ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t.lightningAddress.feedback.saved),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                t.lightningAddress.errors.saving(
                                  details: e.toString(),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(t.common.buttons.saveAndContinue),
                  ),
                ],
              ),
            );
          }

          // Lightning address exists, show offers list as before
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
                      Tooltip(
                        message: t.lightningAddress.feedback.valid,
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
                      tooltip: t.lightningAddress.prompts.edit,
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
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              editFocusNode.requestFocus();
                            });
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Text(t.lightningAddress.prompts.edit),
                                  content: Form(
                                    key: editFormKey,
                                    child: TextFormField(
                                      controller: editController,
                                      focusNode: editFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText:
                                            t.lightningAddress.labels.hint,
                                        labelText:
                                            t.lightningAddress.labels.address,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !value.contains('@')) {
                                          return t
                                              .lightningAddress
                                              .prompts
                                              .invalid;
                                        }
                                        return editValidationError;
                                      },
                                      onChanged: (value) async {
                                        if (value.isNotEmpty &&
                                            value.contains('@')) {
                                          final error =
                                              await validateLightningAddress(
                                                value,
                                                t,
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
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  t
                                                      .lightningAddress
                                                      .feedback
                                                      .updated,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  t.lightningAddress.errors
                                                      .saving(
                                                        details: e.toString(),
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
                                      child: Text(t.common.buttons.cancel),
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
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  t
                                                      .lightningAddress
                                                      .feedback
                                                      .updated,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  t.lightningAddress.errors
                                                      .saving(
                                                        details: e.toString(),
                                                      ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Text(t.common.buttons.save),
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
                    await launchUrl(url);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/simplex.png', height: 24, width: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          t.home.notifications.simplex,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: InkWell(
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://matrix.to/#/#bitblik-offers:matrix.org',
                    );
                    await launchUrl(url);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/element.png', height: 24, width: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          t.home.notifications.element,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: offersAsyncValue.when(
                  data: (offers) {
                    if (offers.isEmpty) {
                      return Center(child: Text(t.offers.display.noAvailable));
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

                    final bool showActiveOffersList = activeOffers.isNotEmpty;

                    return Column(
                      children: [
                        // Active offers
                        if (showActiveOffersList)
                          Expanded(
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
                                                return;
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
                                                  Navigator.of(context).pop();
                                                  ref
                                                      .read(
                                                        errorProvider.notifier,
                                                      )
                                                      .state = t
                                                          .reservations
                                                          .errors
                                                          .failedNoTimestamp;
                                                  if (scaffoldMessenger
                                                      .mounted) {
                                                    scaffoldMessenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          t
                                                              .reservations
                                                              .errors
                                                              .failedNoTimestamp,
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
                                                final errorMsg = t
                                                    .reservations
                                                    .errors
                                                    .failedToReserve(
                                                      details: e.toString(),
                                                    );
                                                ref
                                                    .read(
                                                      errorProvider.notifier,
                                                    )
                                                    .state = errorMsg;
                                                if (scaffoldMessenger.mounted) {
                                                  scaffoldMessenger
                                                      .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            errorMsg,
                                                          ),
                                                        ),
                                                      );
                                                }
                                                ref.invalidate(
                                                  availableOffersProvider,
                                                );
                                              }
                                            },
                                        orElse: () => null,
                                      ),
                                      child: Text(t.offers.actions.take),
                                    );
                                  } else if (isReserved || isBlikReceived) {
                                    trailingWidget = myActiveOfferAsyncValue.when(
                                      data: (myOffer) {
                                        if (myOffer != null &&
                                            offer.id == myOffer.id) {
                                          return ElevatedButton(
                                            child: Text(
                                              t.offers.actions.resume,
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
                                                    );
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
                                                    );
                                              } else {
                                                print(
                                                  "[OfferListScreen] Error: Resuming offer in unexpected state: ${myOffer.status}",
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      t
                                                          .offers
                                                          .errors
                                                          .unexpectedState,
                                                    ),
                                                  ),
                                                );
                                                return;
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
                                          title: Text(
                                            t.offers.details.amountWithCurrency(
                                              amount: formatDouble(
                                                offer.fiatAmount ?? 0.0,
                                              ),
                                              currency: offer.fiatCurrency,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${t.offers.details.amount(amount: offer.amountSats.toString())}\n${t.offers.details.takerFeeWithStatus(fee: offer.takerFees?.toString() ?? "0", status: offer.status)}',
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
                                          maxDuration: _reservationDuration!,
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
                        // Finished offers section
                        if (finishedOffers.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              top: showActiveOffersList ? 16.0 : 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.offers.display.finishedOffers,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height:
                                      72, // further reduce height for compactness
                                  child: Scrollbar(
                                    child: ListView.builder(
                                      shrinkWrap: !showActiveOffersList,
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
                                            title: Text(
                                              t.offers.details
                                                  .amountWithCurrency(
                                                    amount: formatDouble(
                                                      offer.fiatAmount ?? 0.0,
                                                    ),
                                                    currency:
                                                        offer.fiatCurrency,
                                                  ),
                                            ),
                                            subtitle: Text(
                                              '${t.offers.details.amount(amount: offer.amountSats.toString())}\n${t.offers.details.takerFeeWithStatus(fee: offer.takerFees?.toString() ?? "0", status: offer.status)}',
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
                            Text(
                              t.offers.errors.loading(
                                details: error.toString(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed:
                                  () => ref.invalidate(availableOffersProvider),
                              child: Text(t.common.buttons.retry),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
              const Divider(height: 32, thickness: 1),
              _buildStatsSection(
                context,
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
    result += '${seconds}s';
  }
  return result.trim();
}

String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}s ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}

Widget _buildStatsSection(
  BuildContext context,
  AsyncValue<Map<String, dynamic>> statsAsyncValue,
) {
  return statsAsyncValue.when(
    data: (data) {
      final statsMap = data['stats'] as Map<String, dynamic>? ?? {};
      final lifetime = statsMap['lifetime'] as Map<String, dynamic>? ?? {};
      final last7Days = statsMap['last_7_days'] as Map<String, dynamic>? ?? {};

      final recentOffersData = data['offers'] as List<dynamic>? ?? [];
      final recentOffers = recentOffersData.cast<Offer>();

      final numberFormat = NumberFormat(
        "#,##0",
        'en',
      ); // Use 'en' locale for numbers
      final dateFormat =
          DateFormat.yMd('en').add_Hm(); // Use 'en' locale for dates

      final last7DaysBlikTime =
          last7Days['avg_time_blik_received_to_created_seconds'] as num?;
      final last7DaysPaidTime =
          last7Days['avg_time_taker_paid_to_created_seconds'] as num?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.home.statistics.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Combine last 7d and avg stats into one line
                Text(
                  'Last 7d: 	${numberFormat.format(last7Days['count'] ?? 0)}  |  '
                  'Avg BLIK: ${_formatDurationFromSeconds(last7DaysBlikTime?.round())}  |  '
                  'Avg Paid: ${_formatDurationFromSeconds(last7DaysPaidTime?.round())}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                if (recentOffers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(t.offers.display.noSuccessfulTrades),
                  )
                else
                  SizedBox(
                    height: 72, // further reduce height for compactness
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: recentOffers.length,
                        itemBuilder: (context, index) {
                          final offer = recentOffers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 0,
                            ), // less margin
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ), // less padding
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Amount and currency
                                  Text(
                                    t.offers.details.amountWithCurrency(
                                      amount: formatDouble(
                                        offer.fiatAmount ?? 0.0,
                                      ),
                                      currency: offer.fiatCurrency,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Date (now as time ago)
                                  Text(
                                    _formatTimeAgo(offer.createdAt.toLocal()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Taken after (if available)
                                  if (offer.timeToReserveSeconds != null)
                                    Text(
                                      t.offers.details.takenAfter(
                                        duration: _formatDurationFromSeconds(
                                          offer.timeToReserveSeconds,
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  if (offer.timeToReserveSeconds != null)
                                    const SizedBox(width: 8),
                                  // Paid after (if available)
                                  if (offer.totalCompletionTimeTakerSeconds !=
                                      null)
                                    Text(
                                      t.offers.details.paidAfter(
                                        duration: _formatDurationFromSeconds(
                                          offer.totalCompletionTimeTakerSeconds,
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
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
    loading: () => const Center(child: CircularProgressIndicator()),
    error:
        (error, stackTrace) => Center(
          child: Text(
            t.home.statistics.errors.loading(error: error.toString()),
          ),
        ),
  );
}
