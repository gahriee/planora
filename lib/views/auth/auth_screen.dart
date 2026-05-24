import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../components/auth_text_field.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (next.value != null && next.value!.email.isEmpty && previous?.value == null) {
        context.go('/');
      }
    });

    final isLoading = ref.watch(authProvider) is AsyncLoading;
    final theme = Theme.of(context);
    final isLogin = _tabController.index == 0;
    final secondaryTextColor = theme.textTheme.bodySmall?.color;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            'Planora',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Organize your day, your way.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 48),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: secondaryTextColor,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              tabs: [
                                const Tab(text: 'Login'),
                                Tab(text: ref.watch(authProvider).value != null && ref.watch(authProvider).value!.email.isEmpty ? 'Link Account' : 'Sign Up'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val == null || val.isEmpty ? 'Email is required' : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (val) => val == null || val.isEmpty ? 'Password is required' : null,
                          ),
                          const SizedBox(height: 24),
                          if (!isLogin) ...[
                            Text(
                              'Linking an account will permanently save your local tasks to the cloud.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          FilledButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      if (isLogin) {
                                        ref.read(authProvider.notifier).login(
                                              _emailController.text.trim(),
                                              _passwordController.text,
                                            );
                                      } else {
                                        final user = ref.read(authProvider).value;
                                        final isAnonymous = user != null && user.email.isEmpty;
                                        if (isAnonymous) {
                                          ref.read(authProvider.notifier).linkAccount(
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              );
                                        } else {
                                          ref.read(authProvider.notifier).signUp(
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              );
                                        }
                                      }
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    isLogin ? 'Login' : (ref.read(authProvider).value != null && ref.read(authProvider).value!.email.isEmpty ? 'Link Account' : 'Sign Up'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    ref.read(authProvider.notifier).signInAnonymously();
                                  },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Continue as Guest', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 32), // Added extra padding at bottom to avoid overlapping with phone navigation controls
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
