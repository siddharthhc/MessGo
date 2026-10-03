import 'package:flutter/material.dart';

class TodayMenuWidget extends StatelessWidget {
  final Map<String, dynamic> menu;

  const TodayMenuWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 16,
                color: const Color(0xFF00D4FF).withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                "Today's Special",
                style: TextStyle(
                  color: const Color(0xFF00D4FF).withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMenuItem('Lunch', menu['lunch'] ?? 'Dal, Rice, Roti, Salad'),
          const SizedBox(height: 4),
          _buildMenuItem('Dinner', menu['dinner'] ?? 'Paneer, Rice, Roti, Dal'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String meal, String items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$meal: ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            items,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
