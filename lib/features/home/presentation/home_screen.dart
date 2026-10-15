import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/l10n.dart';
import '../../../app/router/app_router.dart';
import '../domain/agent_status.dart';
import '../domain/server_health.dart';
import 'failure_message.dart';
import 'home_providers.dart';

/// Phase-1 home: proves the two integrations every later feature depends on —
/// the backend (health) and the on-device agent runtime (accessibility).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The user enables accessibility in system settings and comes back:
    // re-read the status then, not on a timer.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(agentStatusProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Debug builds: a long press opens the agent console.
        title: GestureDetector(
          key: const Key('home-title'),
          onLongPress: kDebugMode
              ? () => unawaited(context.push(AppRoutes.agentDebug))
              : null,
          child: Text(context.l10n.appTitle),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(serverHealthProvider)
            ..invalidate(agentStatusProvider);
          await Future.wait(<Future<Object?>>[
            ref
                .read(serverHealthProvider.future)
                .then<Object?>((value) => value, onError: (_) => null),
            ref
                .read(agentStatusProvider.future)
                .then<Object?>((value) => value, onError: (_) => null),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const <Widget>[
            ServerStatusCard(),
            SizedBox(height: 12),
            AgentStatusCard(),
          ],
        ),
      ),
    );
  }
}

class ServerStatusCard extends ConsumerWidget {
  const ServerStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ServerHealth> health = ref.watch(serverHealthProvider);
    return Card(
      key: const Key('server-status-card'),
      child: switch (health) {
        AsyncData(:final value) when value.isReady => ListTile(
          leading: const Icon(Icons.cloud_done_outlined),
          title: Text(context.l10n.serverStatusTitle),
          subtitle: Text(context.l10n.serverReady),
        ),
        AsyncData() => _ServerProblem(message: context.l10n.serverUnavailable),
        AsyncError(:final error) => _ServerProblem(
          message: failureMessage(context.l10n, error),
        ),
        _ => ListTile(
          leading: const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(context.l10n.serverStatusTitle),
          subtitle: Text(context.l10n.serverChecking),
        ),
      },
    );
  }
}

class _ServerProblem extends ConsumerWidget {
  const _ServerProblem({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        Icons.cloud_off_outlined,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(context.l10n.serverStatusTitle),
      subtitle: Text(message),
      trailing: TextButton(
        onPressed: () => ref.invalidate(serverHealthProvider),
        child: Text(context.l10n.retry),
      ),
    );
  }
}

class AgentStatusCard extends ConsumerWidget {
  const AgentStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AgentStatus> status = ref.watch(agentStatusProvider);
    return Card(
      key: const Key('agent-status-card'),
      child: switch (status) {
        AsyncData(:final value) => _AgentStatusTile(status: value),
        AsyncError(:final error) => ListTile(
          leading: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(context.l10n.agentStatusTitle),
          subtitle: Text(failureMessage(context.l10n, error)),
        ),
        _ => const ListTile(title: LinearProgressIndicator()),
      },
    );
  }
}

class _AgentStatusTile extends ConsumerWidget {
  const _AgentStatusTile({required this.status});

  final AgentStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String policy = switch (ref.watch(executionPolicyProvider)) {
      ExecutionPolicy.confirmSensitiveActions => context.l10n.policyConfirm,
      ExecutionPolicy.countdown => context.l10n.policyCountdown,
    };
    if (!status.needsSetup) {
      return ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: Text(context.l10n.accessibilityEnabled),
        subtitle: Text(policy),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.agentStatusTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(context.l10n.accessibilityDisabled),
          const SizedBox(height: 4),
          Text(policy, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('enable-accessibility-button'),
            onPressed: () => unawaited(
              ref.read(agentRepositoryProvider).openAccessibilitySettings(),
            ),
            icon: const Icon(Icons.accessibility_new),
            label: Text(context.l10n.enableAccessibility),
          ),
        ],
      ),
    );
  }
}
