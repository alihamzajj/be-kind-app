import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../core/config/supabase_config.dart';
import '../../core/storage/supabase_sync_service.dart';
import '../home/controllers/daily_controller.dart';

enum AuthMode { signIn, signUp, forgotPassword }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_mode == AuthMode.forgotPassword) {
      await _sendPasswordReset();
      return;
    }

    if (email.isEmpty || password.isEmpty || (_mode == AuthMode.signUp && name.isEmpty)) {
      setState(() {
        _errorMessage = 'Please fill out all required fields.';
        _successMessage = null;
      });
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      setState(() {
        _errorMessage = 'Supabase credentials are not configured.';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      if (_mode == AuthMode.signUp) {
        final res = await client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name},
        );
        if (res.user != null) {
          await _syncGuestData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created & data synced!')),
            );
            context.go('/today');
          }
        }
      } else {
        final res = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (res.user != null) {
          await _syncGuestData();
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Welcome back!')));
            context.go('/today');
          }
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
        _successMessage = null;
      });
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      setState(() {
        _errorMessage = 'Supabase credentials are not configured.';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        setState(() {
          _successMessage = 'Password reset link sent to $email!\nCheck your inbox to create a new password.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not send reset link: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _syncGuestData() async {
    final state = ref.read(dailyNotifierProvider);
    await SupabaseSyncService.syncCompletions(state.allCompletions);
    await SupabaseSyncService.syncBadges(state.badges);
    await SupabaseSyncService.updateProfileStats(
      currentStreak: state.streakResult.currentStreak,
      longestStreak: state.streakResult.longestStreak,
      totalActs: state.allCompletions.length,
      fullName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
    );
  }

  String get _title {
    switch (_mode) {
      case AuthMode.signUp:
        return 'Create an Account';
      case AuthMode.forgotPassword:
        return 'Reset Password';
      case AuthMode.signIn:
        return 'Sign In';
    }
  }

  String get _headline {
    switch (_mode) {
      case AuthMode.signUp:
        return 'Keep your kindness streak backed up';
      case AuthMode.forgotPassword:
        return 'Forgot your password?';
      case AuthMode.signIn:
        return 'Welcome back to Be Kind';
    }
  }

  String get _subtitle {
    switch (_mode) {
      case AuthMode.signUp:
      case AuthMode.signIn:
        return 'Sync your streaks, unlocked badges, and personal reflections across all your devices.';
      case AuthMode.forgotPassword:
        return 'Enter your email address and we will send you a secure link to reset your password.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_mode == AuthMode.forgotPassword) {
              setState(() {
                _mode = AuthMode.signIn;
                _errorMessage = null;
                _successMessage = null;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                _headline,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 28),

              if (_mode == AuthMode.signUp) ...[
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'First name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Hide password input completely when resetting password
              if (_mode != AuthMode.forgotPassword) ...[
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                if (_mode == AuthMode.signIn) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _mode = AuthMode.forgotPassword;
                                _errorMessage = null;
                                _successMessage = null;
                              });
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ] else
                  const SizedBox(height: 20),
              ],

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _mode == AuthMode.signUp
                            ? 'Create Account'
                            : (_mode == AuthMode.forgotPassword
                                ? 'Send Reset Link'
                                : 'Sign In'),
                      ),
              ),
              const SizedBox(height: 16),

              if (_mode == AuthMode.forgotPassword)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mode = AuthMode.signIn;
                      _errorMessage = null;
                      _successMessage = null;
                    });
                  },
                  child: const Text('Back to Sign In'),
                )
              else
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mode = _mode == AuthMode.signUp ? AuthMode.signIn : AuthMode.signUp;
                      _errorMessage = null;
                      _successMessage = null;
                    });
                  },
                  child: Text(
                    _mode == AuthMode.signUp
                        ? 'Already have an account? Sign in'
                        : 'New here? Create an account',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
