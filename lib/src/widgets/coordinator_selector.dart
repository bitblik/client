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
  final double? fiatExchangeRate;

  const CoordinatorSelector({
    super.key,
    this.selectedCoordinator,
    this.onCoordinatorSelected,
    this.showInfoOnly = false,
    this.fiatExchangeRate,
  });

  Widget _buildInfoChip(BuildContext context, IconData icon, String text, {Color? iconColor, Color? textColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor ?? Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor ?? Colors.grey)),
      ],
    );
  }

  Future<void> _showCoordinatorPicker(BuildContext context, WidgetRef ref) async {
    final coordinatorsAsync = ref.read(discoveredCoordinatorsProvider);
    if (coordinatorsAsync is AsyncData<List<DiscoveredCoordinator>>) {
      final coordinators = coordinatorsAsync.value;
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children:
                  coordinators.map((coordinator) {
                    final isUnresponsive = coordinator.responsive == false;
                    final rate = fiatExchangeRate ?? 1.0;
                    final minPln = (coordinator.minAmountSats / 100000000.0 * rate).toStringAsFixed(2);
                    final maxPln = (coordinator.maxAmountSats / 100000000.0 * rate).toStringAsFixed(2);
                    final feePct = coordinator.makerFee.toStringAsFixed(2);
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              (coordinator.icon != null && coordinator.icon!.isNotEmpty)
                                  ? (coordinator.icon!.startsWith('http')
                                      ? Image.network(coordinator.icon!, width: 32, height: 32)
                                      : Image.asset(coordinator.icon!, width: 32, height: 32))
                                  : const Icon(Icons.account_circle, size: 32),
                              const SizedBox(width: 8),
                              Text(
                                coordinator.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      (coordinator.responsive == false || coordinator.responsive == null)
                                          ? Colors.grey
                                          : null,
                                ),
                              ),
                              if (coordinator.responsive == true)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                                ),
                              if (coordinator.responsive == false)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Tooltip(
                                    message: 'This coordinator is unresponsive',
                                    preferBelow: false,
                                    child: Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                                  ),
                                ),
                              if (coordinator.responsive == null)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Tooltip(
                                    message: 'Waiting for coordinator response',
                                    preferBelow: false,
                                    child: Icon(Icons.help_outline, color: Colors.amber, size: 18),
                                  ),
                                ),
                              const Spacer(),
                              IconButton(
                                icon: Image.asset('assets/nostr.png', width: 22, height: 22),
                                tooltip: 'View Nostr profile',
                                onPressed:
                                    (coordinator.responsive == false || coordinator.responsive == null)
                                        ? null
                                        : () async {
                                          final url = 'https://njump.me/${Nip19.encodePubKey(coordinator.pubkey)}';
                                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                        },
                              ),
                              if (selectedCoordinator?.pubkey == coordinator.pubkey)
                                Icon(Icons.check, color: Theme.of(context).primaryColor),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (coordinator.version.isNotEmpty)
                                Text(
                                  'v${coordinator.version}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                ),
                              Text('Min/Max: $minPln-$maxPln PLN', style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                '$feePct% fee',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap:
                          (coordinator.responsive == false || coordinator.responsive == null)
                              ? null
                              : () {
                                Navigator.of(context).pop();
                                onCoordinatorSelected?.call(coordinator);
                              },
                      tileColor:
                          (coordinator.responsive == false || coordinator.responsive == null)
                              ? Colors.grey.withOpacity(0.15)
                              : null,
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

    if (selectedCoordinator != null) {
      // Compose details for min/max PLN and maker fee
      final rate = fiatExchangeRate ?? 1.0;
      final minPln = (selectedCoordinator.minAmountSats / 100000000.0 * rate).toStringAsFixed(2);
      final maxPln = (selectedCoordinator.maxAmountSats / 100000000.0 * rate).toStringAsFixed(2);
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
                    (selectedCoordinator.icon != null && selectedCoordinator.icon!.isNotEmpty)
                        ? (selectedCoordinator.icon!.startsWith('http')
                            ? Image.network(selectedCoordinator.icon!, width: 32, height: 32)
                            : Image.asset(selectedCoordinator.icon!, width: 32, height: 32))
                        : const Icon(Icons.account_circle, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      selectedCoordinator.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
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
                      Text(
                        'v${selectedCoordinator.version}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    Text('Min/Max: $minPln-$maxPln PLN', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '$feePct% fee',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
                    ),
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
}
