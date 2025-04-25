import 'dart:async'; // Import async for Timer
import 'dart:async'; // Import async for Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
// import 'taker_flow_screen.dart'; // No longer needed directly
import '../models/offer.dart'; // Import Offer model
import '../services/key_service.dart'; // Import KeyService (still needed for prompt method)
import '../widgets/progress_indicators.dart'; // Import the progress indicators
import 'taker_flow/taker_submit_blik_screen.dart'; // Import new screen
import 'taker_flow/taker_wait_confirmation_screen.dart'; // Import new screen
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _hasValidatedInitialAddress = false;
    _isValidating = false;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _addressFocusNode.dispose();
    super.dispose();
  }

  // Add LNURL validation function
  Future<String?> _validateLightningAddress(String address) async {
    if (!address.contains('@')) {
      return AppLocalizations.of(context)!.lightningAddressInvalid;
    }

    final parts = address.split('@');
    final username = parts[0];
    final domain = parts[1];

    try {
      final lnurlpUrl = Uri.https(domain, '/.well-known/lnurlp/$username');
      final response = await http.get(lnurlpUrl);

      if (response.statusCode != 200) {
        return 'Invalid: Could not fetch LNURL information';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'ERROR') {
        return 'Invalid: ${data['reason']}';
      }

      if (data['tag'] != 'payRequest') {
        return 'Invalid: Not a valid LNURL-pay endpoint';
      }

      if (data['callback'] == null ||
          data['minSendable'] == null ||
          data['maxSendable'] == null) {
        return 'Invalid: Missing required LNURL-pay fields';
      }

      return null; // Validation passed
    } catch (e) {
      return 'Invalid: Could not verify LNURL endpoint';
    }
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

  void _resetToRoleSelection(String message) {
    _refreshTimer?.cancel();
    ref.read(appRoleProvider.notifier).state = AppRole.none;
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    if (scaffoldMessenger != null && message.isNotEmpty) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    }
    context.pop();
    // if (navigator != null && navigator.canPop()) {
    //   navigator.popUntil((route) => route.isFirst);
    // }
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
          return Center(child: Text('Error loading Lightning Address: $e'));
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
            _validateLightningAddress(lightningAddress).then((error) {
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

            return Column(
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
                        final error = await _validateLightningAddress(value);
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
                            const SnackBar(
                              content: Text('Lightning Address saved!'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving address: $e')),
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
                          const SnackBar(
                            content: Text('Lightning Address saved!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving address: $e')),
                        );
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.saveAndContinue),
                ),
              ],
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
                      Tooltip(
                        message: 'Valid Lightning Address',
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
                      tooltip: 'Edit Lightning Address',
                      onPressed: () async {
                        final _editController = TextEditingController(
                          text: lightningAddress,
                        );
                        final _editFormKey = GlobalKey<FormState>();
                        final _editFocusNode = FocusNode();
                        String? _editValidationError;

                        final result = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            // Request focus when the dialog is shown
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _editFocusNode.requestFocus();
                            });
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: const Text('Edit Lightning Address'),
                                  content: Form(
                                    key: _editFormKey,
                                    child: TextFormField(
                                      controller: _editController,
                                      focusNode: _editFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        hintText: 'user@domain.com',
                                        labelText: 'Lightning Address',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !value.contains('@')) {
                                          return 'Please enter a valid Lightning Address';
                                        }
                                        return _editValidationError;
                                      },
                                      onChanged: (value) async {
                                        if (value.isNotEmpty &&
                                            value.contains('@')) {
                                          final error =
                                              await _validateLightningAddress(
                                                value,
                                              );
                                          setState(() {
                                            _editValidationError = error;
                                          });
                                        } else {
                                          setState(() {
                                            _editValidationError = null;
                                          });
                                        }
                                      },
                                      onFieldSubmitted: (value) async {
                                        if (_editFormKey.currentState!
                                                .validate() &&
                                            _editValidationError == null) {
                                          try {
                                            await keyService
                                                .saveLightningAddress(
                                                  _editController.text,
                                                );
                                            ref.invalidate(
                                              lightningAddressProvider,
                                            );
                                            Navigator.of(
                                              context,
                                            ).pop(_editController.text);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Lightning Address updated!',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error saving address: $e',
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
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (_editFormKey.currentState!
                                                .validate() &&
                                            _editValidationError == null) {
                                          try {
                                            await keyService
                                                .saveLightningAddress(
                                                  _editController.text,
                                                );
                                            ref.invalidate(
                                              lightningAddressProvider,
                                            );
                                            Navigator.of(
                                              context,
                                            ).pop(_editController.text);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Lightning Address updated!',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error saving address: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Save'),
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
                    children: [
                      Image.asset('assets/simplex.png', height: 24, width: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Get notified of new orders with SimpleX',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16), // Add some spacing
              Expanded(
                child: offersAsyncValue.when(
                  data: (offers) {
                    if (offers.isEmpty) {
                      return const Center(
                        child: Text('No offers available yet.'),
                      );
                    }
                    // Separate finished offers
                    final finishedStatuses = [
                      OfferStatus.settled.name,
                      OfferStatus.takerPaid.name,
                      OfferStatus.expired.name,
                      OfferStatus.failed.name,
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

                    return Column(
                      children: [
                        // Active offers (as before)
                        if (activeOffers.isNotEmpty)
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
                                                    feeSats: offer.feeSats,
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

                                                  context.push(
                                                    "/submit-blik",
                                                    extra: updatedOffer,
                                                  );
                                                } else {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(); // Pop loading
                                                  ref
                                                          .read(
                                                            errorProvider
                                                                .notifier,
                                                          )
                                                          .state =
                                                      'Failed to reserve offer (no timestamp returned).';
                                                  if (scaffoldMessenger
                                                      .mounted) {
                                                    scaffoldMessenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error: ${ref.read(errorProvider)}',
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
                                                ).canPop())
                                                  Navigator.of(context).pop();
                                                ref
                                                        .read(
                                                          errorProvider
                                                              .notifier,
                                                        )
                                                        .state =
                                                    'Failed to reserve offer: $e';
                                                if (scaffoldMessenger.mounted) {
                                                  scaffoldMessenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: ${ref.read(errorProvider)}',
                                                      ),
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
                                            child: const Text('RESUME'),
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
                                                  const SnackBar(
                                                    content: Text(
                                                      "Error: Offer is in an unexpected state.",
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
                                          title: Text(
                                            "${formatDouble(offer.fiatAmount)} ${offer.fiatCurrency}",
                                          ),
                                          subtitle: Text(
                                            "${offer.amountSats} + ${offer.feeSats} (fee) sats\nStatus: ${offer.status}",
                                          ),
                                          isThreeLine: true,
                                          trailing: trailingWidget,
                                        ),
                                      ),
                                      if (isFunded && offer.createdAt != null)
                                        FundedOfferProgressIndicator(
                                          key: ValueKey(
                                            'progress_funded_${offer.id}',
                                          ),
                                          createdAt: offer.createdAt!,
                                        ),
                                      if (isReserved &&
                                          offer.reservedAt != null)
                                        ReservationProgressIndicator(
                                          key: ValueKey(
                                            'progress_res_${offer.id}',
                                          ),
                                          reservedAt: offer.reservedAt!,
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
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Finished Offers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 200,
                                  child: Scrollbar(
                                    child: ListView.builder(
                                      itemCount: finishedOffers.length,
                                      itemBuilder: (context, index) {
                                        final offer = finishedOffers[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5.0,
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              'Amount: ${offer.amountSats} sats',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Fee: ${offer.feeSats} sats | Status: ${offer.status}\nID: ${offer.id.substring(0, 8)}...',
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
                            Text('Error loading offers: $error'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed:
                                  () => ref.invalidate(availableOffersProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                ),
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
