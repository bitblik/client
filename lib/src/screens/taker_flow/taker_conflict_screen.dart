import '../../../i18n/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TakerConflictScreen extends ConsumerWidget {
  final String offerId;

  const TakerConflictScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.taker.conflict.title),
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                t.taker.conflict.headline,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                t.taker.conflict.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                t.taker.conflict.instructions,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go('/');
                },
                child: Text(t.taker.conflict.actions.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
