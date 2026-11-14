import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../theme/app_theme.dart';
import 'auth_providers.dart';
import 'data/auth_repository.dart';

/// Sign in or create an account with an e-mail address, plus Google where
/// it is configured. The router sends anyone without a session here.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isSignUp = false;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validate() {
    final email = _email.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Geçerli bir e-posta adresi gir.';
    }
    if (_password.text.length < 6) {
      return 'Şifre en az 6 karakter olmalı.';
    }
    if (_isSignUp && _name.text.trim().isEmpty) {
      return 'Sana nasıl hitap edelim? Bir ad yaz.';
    }
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      setState(() {
        _error = problem;
        _info = null;
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    final repository = ref.read(authRepositoryProvider);
    try {
      if (_isSignUp) {
        final outcome = await repository.signUpWithEmail(
          email: _email.text,
          password: _password.text,
          displayName: _name.text,
        );
        if (outcome == SignUpOutcome.confirmationRequired && mounted) {
          setState(() {
            _info =
                'Hesabını doğrulamak için e-postana bir bağlantı '
                'gönderdik. Bağlantıya dokunduktan sonra giriş yapabilirsin.';
            _isSignUp = false;
          });
        }
      } else {
        await repository.signInWithEmail(
          email: _email.text,
          password: _password.text,
        );
      }
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    // On success the router's redirect takes over; nothing to do here.
  }

  Future<void> _google() async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportsGoogle = ref.watch(authRepositoryProvider).supportsGoogle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppScreen(
        child: ListView(
          padding: const EdgeInsets.only(top: 48, bottom: 32),
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '₺',
                  style: AppText.screenTitle.copyWith(
                    color: AppColors.onAccent,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text('Finans Takip', style: AppText.screenTitle)),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _isSignUp
                    ? 'Hesap oluştur, portföyünü takip etmeye başla.'
                    : 'Portföyünü ve alarmlarını görmek için giriş yap.',
                style: AppText.caption,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            if (_isSignUp) ...[
              LabeledField(
                label: 'Ad',
                child: AppTextField(
                  controller: _name,
                  hintText: 'Adın',
                  enabled: !_busy,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
              ),
              const SizedBox(height: 14),
            ],
            LabeledField(
              label: 'E-posta',
              child: AppTextField(
                controller: _email,
                hintText: 'ornek@eposta.com',
                keyboardType: TextInputType.emailAddress,
                enabled: !_busy,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Şifre',
              child: AppTextField(
                controller: _password,
                hintText: 'En az 6 karakter',
                obscureText: true,
                enabled: !_busy,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _busy ? null : _submit(),
                autofillHints: const [AutofillHints.password],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                style: AppText.caption.copyWith(color: AppColors.down),
              ),
            ],
            if (_info != null) ...[
              const SizedBox(height: 14),
              Text(
                _info!,
                style: AppText.caption.copyWith(color: AppColors.up),
              ),
            ],
            const SizedBox(height: 22),
            AccentButton(
              label: _busy
                  ? 'Lütfen bekle…'
                  : (_isSignUp ? 'Hesap oluştur' : 'Giriş yap'),
              onPressed: _busy ? null : _submit,
            ),
            if (supportsGoogle) ...[
              const SizedBox(height: 12),
              GhostButton(
                label: 'Google ile devam et',
                onPressed: _busy ? null : _google,
              ),
            ],
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _isSignUp = !_isSignUp;
                        _error = null;
                        _info = null;
                      }),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  minimumSize: const Size(AppSpacing.minTapTarget, 44),
                ),
                child: Text(
                  _isSignUp
                      ? 'Zaten hesabın var mı? Giriş yap'
                      : 'Hesabın yok mu? Kayıt ol',
                  style: AppText.captionSmall.copyWith(
                    color: AppColors.accent,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Veriler bilgi amaçlıdır, yatırım tavsiyesi değildir.',
                style: AppText.captionSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
