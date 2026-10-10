import 'package:flutter/material.dart';
import '../providers/app_state.dart';

class HandleSetupDialog extends StatefulWidget {
  final AppState appState;

  const HandleSetupDialog({super.key, required this.appState});

  @override
  State<HandleSetupDialog> createState() => _HandleSetupDialogState();
}

class _HandleSetupDialogState extends State<HandleSetupDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.appState.chatService.currentHandle != null) {
      _controller.text = widget.appState.chatService.currentHandle!.replaceAll('@', '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid handle.');
      return;
    }

    final success = await widget.appState.chatService.saveUserHandle(input);
    if (success) {
      if (mounted) {
        Navigator.pop(context, widget.appState.chatService.currentHandle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registered handle ${widget.appState.chatService.currentHandle}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => _errorMessage = 'Handle must be at least 3 characters.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAstro = widget.appState.isAstroRedMode;

    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      title: const Row(
        children: [
          Icon(Icons.account_circle, color: Colors.amber),
          SizedBox(width: 8),
          Text('Reserve Stargazer Handle'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guest browsing is 100% free! Reserving a handle is only needed to post messages in Nepal & Asia chat rooms.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              prefixText: '@ ',
              labelText: 'Choose your handle',
              hintText: 'e.g. cosmos_nepal',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
            foregroundColor: Colors.black,
          ),
          onPressed: _submit,
          child: const Text('Reserve Handle'),
        ),
      ],
    );
  }
}
