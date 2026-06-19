import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/auth/auth_repository.dart';
import 'package:starter_app/core/config/app_config.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthRepository>();
    final bool ok;
    if (_tabs.index == 0) {
      ok = await auth.signIn(_emailCtrl.text, _passwordCtrl.text);
    } else {
      ok = await auth.signUp(
        _emailCtrl.text,
        _passwordCtrl.text,
        _nameCtrl.text,
      );
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Check your email to confirm.'),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
    if (!ok && mounted) {
      final err =
          context.read<AuthRepository>().error ?? 'Something went wrong.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConfigured = AppConfig.isConfigured;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Todo',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isConfigured
                        ? 'Sign in to sync and share your tasks'
                        : 'Configure Supabase in AppConfig to enable cloud sync',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (isConfigured) ...[
                    Card(
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabs,
                            tabs: const [
                              Tab(text: 'Sign In'),
                              Tab(text: 'Sign Up'),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: AnimatedBuilder(
                                animation: _tabs,
                                builder: (_, _) => Column(
                                  children: [
                                    if (_tabs.index == 1) ...[
                                      TextFormField(
                                        controller: _nameCtrl,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: const InputDecoration(
                                          labelText: 'Display name',
                                        ),
                                        validator: (v) =>
                                            (_tabs.index == 1 &&
                                                (v == null || v.trim().isEmpty))
                                            ? 'Name is required'
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    TextFormField(
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                      ),
                                      validator: (v) =>
                                          (v == null || !v.contains('@'))
                                          ? 'Valid email required'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _passwordCtrl,
                                      obscureText: _obscure,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscure
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscure = !_obscure,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.length < 6)
                                          ? 'Min 6 characters'
                                          : null,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _submit,
                                        child: _loading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                _tabs.index == 0
                                                    ? 'Sign In'
                                                    : 'Create Account',
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.wifi_off_outlined),
                    label: const Text('Continue Offline'),
                    onPressed: () =>
                        context.read<AuthRepository>().continueOffline(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
