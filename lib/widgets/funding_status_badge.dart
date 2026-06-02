import 'package:flutter/material.dart';

class FundingStatusBadge extends StatelessWidget {
  const FundingStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA000);
      case 'in_progress':
        return const Color(0xFF1565C0);
      case 'successful':
        return const Color(0xFF2E7D32);
      case 'no_response':
        return const Color(0xFF757575);
      case 'no_deal':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF757575);
    }
  }

  String _getDisplayLabel() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'successful':
        return 'Successful';
      case 'no_response':
        return 'No Response';
      case 'no_deal':
        return 'No Deal';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getDisplayLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
