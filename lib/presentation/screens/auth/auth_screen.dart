import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _isTokenVisible = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .authenticate(_tokenController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.tertiaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero section with animated train icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.train,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Train Rides',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track Your Rail Adventures',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Main content card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your Baserow API token to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _tokenController,
                            obscureText: !_isTokenVisible,
                            decoration: InputDecoration(
                              labelText: 'API Token',
                              hintText: 'Enter your Baserow API token',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.vpn_key,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isTokenVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isTokenVisible = !_isTokenVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your API token';
                              }
                              if (value.trim().length < 10) {
                                return 'Token seems too short';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleSubmit(),
                          ),
                          const SizedBox(height: 24),
                          authState.when(
                            data: (state) {
                              if (state.hasError) {
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              state.error ??
                                                  'Authentication failed',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onErrorContainer,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.refresh),
                                          SizedBox(width: 8),
                                          Text(
                                            'Try Again',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return ElevatedButton(
                                onPressed: _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login),
                                    SizedBox(width: 8),
                                    Text(
                                      'Authenticate',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Authenticating...',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            error: (error, stack) => Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Authentication failed: ${error.toString()}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onErrorContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh),
                                      SizedBox(width: 8),
                                      Text(
                                        'Try Again',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'How to get your API token:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoStep(
                              '1',
                              'Go to your Baserow account settings',
                            ),
                            _buildInfoStep(
                              '2',
                              'Navigate to the "API tokens" section',
                            ),
                            _buildInfoStep(
                              '3',
                              'Create a new token with read/write permissions',
                            ),
                            _buildInfoStep(
                              '4',
                              'Copy the token and paste it above',
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Your token will be stored securely on this device.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
