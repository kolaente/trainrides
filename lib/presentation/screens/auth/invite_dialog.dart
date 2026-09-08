import 'package:flutter/material.dart';

typedef Invitation = ({String code, bool claim});

class InviteDialog extends StatefulWidget {
  const InviteDialog({super.key});

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _claim = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(
        context,
      ).pop<Invitation>((code: _controller.text.trim(), claim: _claim));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Join with an invite'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the invite code you received. Your password must have at least 8 characters.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Invite code'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your invite code'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Claim my existing account'),
              subtitle: const Text(
                'Keep your rides from the previous app. Use your existing email and choose a new password.',
              ),
              value: _claim,
              onChanged: (value) => setState(() => _claim = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Continue')),
    ],
  );
}
