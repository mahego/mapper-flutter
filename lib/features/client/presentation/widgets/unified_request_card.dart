import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/request_repository.dart';

class UnifiedRequestCard extends StatelessWidget {
  final UnifiedRequestItem item;
  final VoidCallback onTap;
  final VoidCallback? onTrack;

  const UnifiedRequestCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onTrack,
  });

  static const _statusLabels = {
    'pending': 'Pendiente',
    'rejected': 'Rechazada',
    'accepted': 'Aceptada',
    'in_progress': 'En Progreso',
    'completed': 'Completada',
    'cancelled': 'Cancelada',
  };

  Color _getStatusColor() {
    switch (item.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel => _statusLabels[item.status.toLowerCase()] ?? item.status;

  @override
  Widget build(BuildContext context) {
    final canTrack = item.type == UnifiedRequestType.service &&
        (item.status == 'in_progress' || item.status == 'accepted');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _getStatusColor().withOpacity(0.5)),
                  ),
                  child: Text(_statusLabel, style: TextStyle(color: _getStatusColor(), fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    item.type == UnifiedRequestType.service ? 'Servicio' : 'Tienda',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
                  ),
                ),
                const Spacer(),
                Text('ID #${item.id}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            if (item.type == UnifiedRequestType.service && (item.serviceTypeName != null || item.serviceCategory != null))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.serviceCategory != null)
                      _chip('${item.serviceCategory}', const Color(0xFF06b6d4)),
                    if (item.serviceTypeName != null)
                      _chip(item.serviceTypeName!, Colors.orange),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place, size: 18, color: Colors.white.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type == UnifiedRequestType.store ? 'Entrega en' : 'Origen',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                      ),
                      Text(
                        item.location,
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.storeName != null) ...[
              const SizedBox(height: 6),
              Text('Tienda: ${item.storeName}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
            ],
            if (item.providerName != null) ...[
              const SizedBox(height: 4),
              Text('Proveedor: ${item.providerName}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(item.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
                Text(
                  NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.amount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF06b6d4)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Ver detalles'),
                  ),
                ),
                if (canTrack && onTrack != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onTrack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06b6d4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Tracking'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy, HH:mm', 'es').format(d);
    } catch (_) {
      return iso;
    }
  }
}
