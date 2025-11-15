import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../i18n/gen/strings.g.dart';
import '../providers/providers.dart';
import '../utils/ln.dart';
import 'package:ndk/shared/logger/logger.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const routeName = '/wallet';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final lightningAddressAsync = ref.watch(lightningAddressProvider);
    final keyService = ref.read(keyServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.wallet.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Description card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.wallet.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Lightning Address Section
          Text(
            t.lightningAddress.labels.address,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          lightningAddressAsync.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, s) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t.lightningAddress.errors.loading(details: e.toString()),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            data: (lightningAddress) {
              final hasLightningAddress =
                  lightningAddress != null && lightningAddress.isNotEmpty;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasLightningAddress) ...[
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.lightningAddress.labels.receivingAddress,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lightningAddress,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await _showEditLightningAddressDialog(
                                  context,
                                  ref,
                                  lightningAddress,
                                  keyService,
                                  t,
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: Text(t.lightningAddress.prompts.edit),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () async {
                                await _showDeleteLightningAddressDialog(
                                  context,
                                  ref,
                                  keyService,
                                  t,
                                );
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: Text(
                                t.lightningAddress.prompts.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t.lightningAddress.prompts.missing,
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.lightningAddress.prompts.howToGet,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () async {
                                        final uri = Uri.parse('https://lightningaddress.com/');
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                      child: Text(
                                        t.lightningAddress.prompts.learnMore,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _showEditLightningAddressDialog(
                                context,
                                ref,
                                null,
                                keyService,
                                t,
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: Text(t.lightningAddress.prompts.add),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditLightningAddressDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentAddress,
    dynamic keyService,
    Translations t,
  ) async {
    final editController = TextEditingController(text: currentAddress);
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
              title: Text(
                currentAddress == null
                    ? t.lightningAddress.prompts.add
                    : t.lightningAddress.prompts.edit,
              ),
              content: Form(
                key: editFormKey,
                child: TextFormField(
                  controller: editController,
                  focusNode: editFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: t.lightningAddress.labels.hint,
                    labelText: t.lightningAddress.labels.address,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return t.lightningAddress.prompts.invalid;
                    }
                    return editValidationError;
                  },
                  onChanged: (value) async {
                    if (value.isNotEmpty && value.contains('@')) {
                      final error = await validateLightningAddress(value, t);
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
                    Logger.log.d('[Wallet Screen] onFieldSubmitted called with: $value');
                    
                    // First validate the form format
                    if (!editFormKey.currentState!.validate()) {
                      Logger.log.d('[Wallet Screen] Form validation failed');
                      return;
                    }
                    
                    // Then perform async validation
                    if (value.isNotEmpty && value.contains('@')) {
                      Logger.log.d('[Wallet Screen] Starting async validation...');
                      try {
                        final error = await validateLightningAddress(value, t);
                        Logger.log.d('[Wallet Screen] Validation result: ${error ?? "SUCCESS"}');
                        if (!context.mounted) return;
                        setState(() {
                          editValidationError = error;
                        });
                        
                        // If there's a validation error, show it and return
                        if (error != null) {
                          Logger.log.d('[Wallet Screen] Validation failed, showing error');
                          editFormKey.currentState!.validate();
                          return;
                        }
                      } catch (e) {
                        Logger.log.d('[Wallet Screen] Validation threw exception: $e');
                        if (!context.mounted) return;
                        setState(() {
                          editValidationError = t.lightningAddress.prompts.invalid;
                        });
                        editFormKey.currentState!.validate();
                        return;
                      }
                    }
                    
                    // Save the address
                    Logger.log.d('[Wallet Screen] Attempting to save address...');
                    try {
                      await keyService.saveLightningAddress(
                        editController.text,
                      );
                      Logger.log.d('[Wallet Screen] Address saved successfully');
                      if (!context.mounted) return;
                      ref.invalidate(lightningAddressProvider);
                      Navigator.of(context).pop(editController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            currentAddress == null
                                ? t.lightningAddress.feedback.saved
                                : t.lightningAddress.feedback.updated,
                          ),
                        ),
                      );
                    } catch (e) {
                      Logger.log.d('[Wallet Screen] Save failed: $e');
                      if (!context.mounted) return;
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
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.common.buttons.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    // First validate the form format
                    if (!editFormKey.currentState!.validate()) {
                      return;
                    }
                    
                    // Then perform async validation
                    final value = editController.text;
                    if (value.isNotEmpty && value.contains('@')) {
                      try {
                        final error = await validateLightningAddress(value, t);
                        if (!context.mounted) return;
                        setState(() {
                          editValidationError = error;
                        });
                        
                        // If there's a validation error, show it and return
                        if (error != null) {
                          editFormKey.currentState!.validate();
                          return;
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        setState(() {
                          editValidationError = t.lightningAddress.prompts.invalid;
                        });
                        editFormKey.currentState!.validate();
                        return;
                      }
                    }
                    
                    // Save the address
                    try {
                      await keyService.saveLightningAddress(
                        editController.text,
                      );
                      if (!context.mounted) return;
                      ref.invalidate(lightningAddressProvider);
                      Navigator.of(context).pop(editController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            currentAddress == null
                                ? t.lightningAddress.feedback.saved
                                : t.lightningAddress.feedback.updated,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
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
                  },
                  child: Text(t.common.buttons.save),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null && result != currentAddress) {
      ref.invalidate(lightningAddressProvider);
    }
  }

  Future<void> _showDeleteLightningAddressDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic keyService,
    Translations t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.lightningAddress.prompts.delete),
          content: Text(t.lightningAddress.prompts.confirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.common.buttons.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(t.lightningAddress.prompts.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await keyService.saveLightningAddress('');
        ref.invalidate(lightningAddressProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.lightningAddress.feedback.updated)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t.lightningAddress.errors.saving(details: e.toString()),
              ),
            ),
          );
        }
      }
    }
  }
}

