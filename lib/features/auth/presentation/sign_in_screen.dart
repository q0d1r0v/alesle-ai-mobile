import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/alesle_orb.dart';
import '../../../app/widgets/capsule_button.dart';
import '../data/auth_data_providers.dart';
import '../domain/auth_repository.dart';
import 'auth_messages.dart';

enum _Mode { options, signIn, register, linkSent }

/// Sign-in (SOW 06 §1, onboarding step 9): Google, email + password, or a
/// one-time link. Signing in moves the router on by itself.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  _Mode _mode = _Mode.options;
  bool _busy = false;
  String? _error;

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = authFailureMessage(context.l10n, error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final AuthRepository auth = _auth;
    unawaited(
      _run(
        () => _mode == _Mode.register
            ? auth.register(
                email: _email.text,
                password: _password.text,
                displayName: _name.text,
              )
            : auth.signInWithPassword(
                email: _email.text,
                password: _password.text,
              ),
      ),
    );
  }

  void _sendLink() {
    final String? problem = _emailProblem(context.l10n, _email.text);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final AuthRepository auth = _auth;
    unawaited(
      _run(() async {
        await auth.sendMagicLink(_email.text);
        if (mounted) setState(() => _mode = _Mode.linkSent);
      }),
    );
  }

  void _google() {
    final AuthRepository auth = _auth;
    unawaited(_run(() async => auth.signInWithGoogle()));
  }

  void _show(_Mode mode) => setState(() {
    _mode = mode;
    _error = null;
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    return PopScope(
      canPop: _mode == _Mode.options,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _show(_Mode.options);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_mode != _Mode.options)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filledTonal(
                      key: const Key('sign-in-back'),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _busy ? null : () => _show(_Mode.options),
                      icon: const Icon(Icons.chevron_left_rounded),
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                    ),
                  )
                else
                  const SizedBox(height: 48),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 16),
                        if (_mode == _Mode.options) ...<Widget>[
                          const Center(child: AlesleOrb(size: 120)),
                          const SizedBox(height: 32),
                        ],
                        Text(
                          _mode == _Mode.linkSent
                              ? l10n.signInLinkSentTitle
                              : l10n.signInTitle,
                          key: const Key('sign-in-title'),
                          style: text.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mode == _Mode.linkSent
                              ? l10n.signInLinkSentBody(_email.text.trim())
                              : l10n.signInBody,
                          style: text.bodyLarge?.copyWith(
                            color: AlesleColors.text2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_mode == _Mode.signIn || _mode == _Mode.register)
                          _EmailForm(
                            formKey: _form,
                            email: _email,
                            password: _password,
                            name: _name,
                            register: _mode == _Mode.register,
                            onSubmit: _busy ? null : _submit,
                          ),
                        if (_error case final String message) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            message,
                            key: const Key('sign-in-error'),
                            style: text.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._actions(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(AppLocalizations l10n) {
    final VoidCallback? idle = _busy ? null : () {};
    switch (_mode) {
      case _Mode.options:
        return <Widget>[
          if (_auth.googleAvailable) ...<Widget>[
            CapsuleButton(
              key: const Key('sign-in-google'),
              label: _busy ? l10n.signInSigningIn : l10n.signInGoogle,
              icon: Icons.account_circle_outlined,
              onPressed: idle == null ? null : _google,
            ),
            const SizedBox(height: 8),
          ],
          CapsuleButton(
            key: const Key('sign-in-email'),
            label: l10n.signInEmail,
            style: _auth.googleAvailable
                ? CapsuleStyle.secondary
                : CapsuleStyle.primary,
            icon: Icons.mail_outline_rounded,
            onPressed: idle == null ? null : () => _show(_Mode.signIn),
          ),
        ];
      case _Mode.signIn:
      case _Mode.register:
        final bool register = _mode == _Mode.register;
        return <Widget>[
          CapsuleButton(
            key: const Key('sign-in-submit'),
            label: _busy
                ? l10n.signInSigningIn
                : (register ? l10n.signInCreateButton : l10n.signInButton),
            onPressed: idle == null ? null : _submit,
          ),
          TextButton(
            key: const Key('sign-in-switch'),
            onPressed: idle == null
                ? null
                : () => _show(register ? _Mode.signIn : _Mode.register),
            child: Text(register ? l10n.signInToSignIn : l10n.signInToCreate),
          ),
          TextButton(
            key: const Key('sign-in-send-link'),
            onPressed: idle == null ? null : _sendLink,
            child: Text(l10n.signInSendLink),
          ),
        ];
      case _Mode.linkSent:
        return <Widget>[
          CapsuleButton(
            key: const Key('sign-in-other-way'),
            label: l10n.signInBackToOptions,
            style: CapsuleStyle.secondary,
            onPressed: () => _show(_Mode.options),
          ),
        ];
    }
  }
}

String? _emailProblem(AppLocalizations l10n, String? value) {
  final String email = (value ?? '').trim();
  final bool looksRight = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  return looksRight ? null : l10n.signInBadEmail;
}

class _EmailForm extends StatelessWidget {
  const _EmailForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.name,
    required this.register,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController name;
  final bool register;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Form(
      key: formKey,
      child: AutofillGroup(
        child: Column(
          children: <Widget>[
            if (register) ...<Widget>[
              TextFormField(
                key: const Key('sign-in-name'),
                controller: name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const <String>[AutofillHints.name],
                decoration: InputDecoration(labelText: l10n.signInNameLabel),
                maxLength: 80,
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              key: const Key('sign-in-email-field'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.email],
              autocorrect: false,
              decoration: InputDecoration(labelText: l10n.signInEmailLabel),
              validator: (String? value) => _emailProblem(l10n, value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('sign-in-password'),
              controller: password,
              obscureText: true,
              autofillHints: <String>[
                if (register)
                  AutofillHints.newPassword
                else
                  AutofillHints.password,
              ],
              decoration: InputDecoration(labelText: l10n.signInPasswordLabel),
              onFieldSubmitted: (_) => onSubmit?.call(),
              validator: (String? value) =>
                  (value ?? '').length < 8 ? l10n.signInShortPassword : null,
            ),
          ],
        ),
      ),
    );
  }
}
