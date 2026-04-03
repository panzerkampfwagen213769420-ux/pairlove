import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = [
      _CallItem(
        name: 'Partner',
        time: 'Dzisiaj, 14:30',
        duration: '5:42',
        type: CallType.video,
        isIncoming: true,
      ),
      _CallItem(
        name: 'Partner',
        time: 'Wczoraj, 20:15',
        duration: '12:30',
        type: CallType.voice,
        isIncoming: true,
      ),
      _CallItem(
        name: 'Partner',
        time: '2 dni temu, 18:45',
        duration: '8:20',
        type: CallType.video,
        isIncoming: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Połączenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickCallButton(
                    icon: Icons.call,
                    label: 'Połączenie',
                    color: Colors.green,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickCallButton(
                    icon: Icons.videocam,
                    label: 'Wideo',
                    color: AppTheme.primaryColor,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                return _buildCallTile(call);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallTile(_CallItem call) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
        child: Icon(
          call.type == CallType.video ? Icons.videocam : Icons.call,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        call.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          Icon(
            call.isIncoming ? Icons.call_received : Icons.call_made,
            size: 14,
            color: call.isIncoming ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(call.time),
          const SizedBox(width: 8),
          Text(
            call.duration,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          call.type == CallType.video ? Icons.videocam : Icons.call,
          color: AppTheme.primaryColor,
        ),
        onPressed: () {},
      ),
    );
  }
}

enum CallType { voice, video }

class _CallItem {
  final String name;
  final String time;
  final String duration;
  final CallType type;
  final bool isIncoming;

  _CallItem({
    required this.name,
    required this.time,
    required this.duration,
    required this.type,
    required this.isIncoming,
  });
}