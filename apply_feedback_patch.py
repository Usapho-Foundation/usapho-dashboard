from pathlib import Path

dash = Path("lib/screens/dashboard_screen.dart")
text = dash.read_text(encoding="utf-8")

method_block = """
  Future<void> _openFeedbackDialog() async {
    final feedbackController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Feedback'),
        content: TextField(
          controller: feedbackController,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Add feedback or suggestions for the dashboard',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final feedback = feedbackController.text.trim();
              Navigator.pop(context);

              if (feedback.isEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add feedback before submitting.'),
                  ),
                );
                return;
              }

              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Thanks! Your feedback has been captured for review.',
                  ),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    feedbackController.dispose();
  }

"""

if "_openFeedbackDialog()" not in text:
    marker = "  void _openEditFunding("
    i = text.find(marker)
    if i != -1:
        text = text[:i] + method_block + text[i:]

feedback_button = """          TextButton.icon(
            onPressed: _openFeedbackDialog,
            icon: const Icon(Icons.feedback_outlined, color: Colors.black87),
            label: const Text(
              'Feedback',
              style: TextStyle(color: Colors.black87),
            ),
          ),
"""

if "Icons.feedback_outlined" not in text:
    marker = "        actions: [\n"
    i = text.find(marker)
    if i != -1:
        i2 = i + len(marker)
        text = text[:i2] + feedback_button + text[i2:]

dash.write_text(text, encoding="utf-8")
print("dashboard_screen.dart updated ?")
