
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _Header(),
                SizedBox(height: 48),
                _SignUpForm(),
                SizedBox(height: 32),
                _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.eco, color: theme.colorScheme.primary, size: 32),
            const SizedBox(width: 8),
            Text(
              'Fluid Scholar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Start learning.',
          style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Join our digital sanctuary and explore without limits.',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'e.g. Jane Doe',
             border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('School Level', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _SchoolLevelChip(label: 'Middle School'),
            _SchoolLevelChip(label: 'High School', isActive: true),
            _SchoolLevelChip(label: 'Undergraduate'),
            _SchoolLevelChip(label: 'Postgraduate'),
          ],
        ),
        const SizedBox(height: 24),
        TextFormField(
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '••••••••',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Create Account'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
             textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }
}

class _SchoolLevelChip extends StatelessWidget {
  const _SchoolLevelChip({
    required this.label,
    this.isActive = false,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (selected) {},
      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.2),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
         side: const BorderSide(
           width: 0,
           color: Colors.transparent
         )
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
    );
  }
}


class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () {},
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}
