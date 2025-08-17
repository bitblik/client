import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../i18n/gen/strings.g.dart';
import '../providers/providers.dart';
import '../services/nostr_service.dart';

class CoordinatorSelector extends ConsumerWidget {
  final DiscoveredCoordinator? selectedCoordinator;
  final Function(DiscoveredCoordinator)? onCoordinatorSelected;
  final bool showInfoOnly;
  final bool summaryMode;
  final double? fiatExchangeRate;

  const CoordinatorSelector({
    Key? key,
    this.selectedCoordinator,
    this.onCoordinatorSelected,
    this.showInfoOnly = false,
    this.summaryMode = false,
    this.fiatExchangeRate,
  }) : super(key: key);

  Widget _buildCoordinatorCard(
    BuildContext context,
    DiscoveredCoordinator coordinator, {
    bool isSelected = false,
    Function(DiscoveredCoordinator)? onTap,
    bool showInfoOnly = false,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap:
            showInfoOnly
                ? null
                : () {
                  onTap?.call(coordinator);
                },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Coordinator icon
                  if (coordinator.icon != null && coordinator.icon!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child:
                          coordinator.icon!.startsWith('http')
                              ? Image.network(
                                coordinator.icon!,
                                width: 24,
                                height: 24,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.account_circle,
                                      size: 24,
                                    ),
                              )
                              : Image.asset(
                                coordinator.icon!,
                                width: 24,
                                height: 24,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.account_circle,
                                      size: 24,
                                    ),
                              ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.account_circle, size: 24),
                    ),

                  // Coordinator name and version
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coordinator.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        if (coordinator.version.isNotEmpty)
                          Text(
                            'v${coordinator.version}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),

                  // Status indicator
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),

                  // External link button
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    onPressed: () async {
                      final url = 'https://njump.me/${Nip19.encodePubKey(coordinator.pubkey)}';
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Coordinator details
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    context,
                    Icons.account_balance_wallet,
                    'Range: ${(coordinator.minAmountSats / 100000000).toStringAsFixed(6)} - ${(coordinator.maxAmountSats / 100000000).toStringAsFixed(6)} BTC',
                  ),
                  _buildInfoChip(
                    context,
                    Icons.percent,
                    'Maker: ${coordinator.makerFee.toStringAsFixed(2)}%',
                  ),
                  _buildInfoChip(
                    context,
                    Icons.percent,
                    'Taker: ${coordinator.takerFee.toStringAsFixed(2)}%',
                  ),
                  if (coordinator.currencies.isNotEmpty)
                    _buildInfoChip(
                      context,
                      Icons.attach_money,
                      coordinator.currencies.join(', '),
                    ),
                  _buildInfoChip(
                    context,
                    Icons.schedule,
                    'Timeout: ${coordinator.reservationSeconds}s',
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Last seen
              Text(
                'Last seen: ${_formatLastSeen(coordinator.lastSeen)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _showCoordinatorPicker(BuildContext context,
      WidgetRef ref) async {
    final coordinatorsAsync = ref.read(discoveredCoordinatorsProvider);
    if (coordinatorsAsync is AsyncData<List<DiscoveredCoordinator>>) {
      final coordinators = coordinatorsAsync.value;
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: coordinators.map((coordinator) {
                final rate = fiatExchangeRate ?? 1.0;
                final minPln = (coordinator.minAmountSats / 100000000.0 * rate)
                    .toStringAsFixed(2);
                final maxPln = (coordinator.maxAmountSats / 100000000.0 * rate)
                    .toStringAsFixed(2);
                final feePct = coordinator.makerFee.toStringAsFixed(2);
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          (coordinator.icon != null &&
                              coordinator.icon!.isNotEmpty)
                              ? (coordinator.icon!.startsWith('http')
                              ? Image.network(
                              coordinator.icon!, width: 32, height: 32)
                              : Image.asset(
                              coordinator.icon!, width: 32, height: 32))
                              : const Icon(Icons.account_circle, size: 32),
                          const SizedBox(width: 8),
                          Text(coordinator.name,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          IconButton(
                            icon: Image.asset(
                              'assets/nostr.png',
                              width: 22, height: 22,
                            ),
                            tooltip: 'View Nostr profile',
                            onPressed: () async {
                              final url = 'https://njump.me/${Nip19
                                  .encodePubKey(coordinator.pubkey)}';
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
                          if (selectedCoordinator?.pubkey == coordinator.pubkey)
                            Icon(Icons.check, color: Theme
                                .of(context)
                                .primaryColor)
                        ],
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (coordinator.version.isNotEmpty)
                            Text('v${coordinator.version}', style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey)),
                          Text('Min/Max: $minPln-$maxPln PLN', style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall),
                          Text('$feePct% fee', style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.blueGrey)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onCoordinatorSelected?.call(coordinator);
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinatorsAsync = ref.watch(discoveredCoordinatorsProvider);
    final selectedCoordinator = this.selectedCoordinator;

    if (summaryMode) {
      if (selectedCoordinator != null) {
        // Compose details for min/max PLN and maker fee
        final rate = fiatExchangeRate ?? 1.0;
        final minPln = (selectedCoordinator.minAmountSats / 100000000.0 * rate)
            .toStringAsFixed(2);
        final maxPln = (selectedCoordinator.maxAmountSats / 100000000.0 * rate)
            .toStringAsFixed(2);
        final feePct = selectedCoordinator.makerFee.toStringAsFixed(2);
        return GestureDetector(
          onTap: () => _showCoordinatorPicker(context, ref),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      (selectedCoordinator.icon != null &&
                          selectedCoordinator.icon!.isNotEmpty) ?
                      (selectedCoordinator.icon!.startsWith('http')
                          ? Image.network(
                          selectedCoordinator.icon!, width: 32, height: 32)
                          : Image.asset(
                          selectedCoordinator.icon!, width: 32, height: 32))
                          : const Icon(Icons.account_circle, size: 32),
                      const SizedBox(width: 8),
                      Text(selectedCoordinator.name,
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (selectedCoordinator.version.isNotEmpty)
                        Text('v${selectedCoordinator.version}', style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey)),
                      Text('Min/Max: $minPln-$maxPln PLN', style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall),
                      Text('$feePct% fee', style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.blueGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.hub),
            label: Text('Choose Coordinator'),
            onPressed: () => _showCoordinatorPicker(context, ref),
          ),
        );
      }
    }

    return coordinatorsAsync.when(
      data: (coordinators) {
        if (coordinators.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.search, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Discovering coordinators...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Looking for BitBlik coordinators on the Nostr network',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
              ),
            ),
          );
        }

        if (showInfoOnly && selectedCoordinator != null) {
          return _buildCoordinatorCard(
            context,
            selectedCoordinator,
            isSelected: true,
            showInfoOnly: true,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with coordinator count and refresh button
            Row(
              children: [
                Icon(Icons.hub, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Select Coordinator',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${coordinators.length} found',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    ref.read(discoveredCoordinatorsProvider.notifier).refresh();
                  },
                  tooltip: 'Refresh coordinators',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Coordinator list
            Column(
              children:
                  coordinators.map((coordinator) {
                    final isSelected =
                        selectedCoordinator?.pubkey == coordinator.pubkey;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildCoordinatorCard(
                        context,
                        coordinator,
                        isSelected: isSelected,
                        onTap: onCoordinatorSelected,
                        showInfoOnly: showInfoOnly,
                      ),
                    );
                  }).toList(),
            ),
          ],
        );
      },
      loading:
          () => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Connecting to Nostr network...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      error:
          (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 8),
                  Text(
                    'Error discovering coordinators',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
