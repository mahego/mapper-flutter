import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/request_repository.dart';
import '../../../../core/theme/app_icons.dart';

/// Card de solicitud unificada (servicio o tienda) – diseño homologado con la web.
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

  static final _statusColors = <String, _StatusStyle>{
    'pending': _StatusStyle(Color(0xFFeab308), Color(0xFFca8a04)),
    'rejected': _StatusStyle(Color(0xFFef4444), Color(0xFFb91c1c)),
    'accepted': _StatusStyle(Color(0xFF22c55e), Color(0xFF15803d)),
    'in_progress': _StatusStyle(Color(0xFF3b82f6), Color(0xFF2563eb)),
    'completed': _StatusStyle(Color(0xFF10b981), Color(0xFF059669)),
    'cancelled': _StatusStyle(Color(0xFF6b7280), Color(0xFF4b5563)),
  };

  String get _statusLabel => _statusLabels[item.status.toLowerCase()] ?? item.status;

  _StatusStyle get _statusStyle =>
      _statusColors[item.status.toLowerCase()] ?? _StatusStyle(Colors.grey, Colors.grey.shade700);

  bool get _canTrack =>
      item.type == UnifiedRequestType.service &&
      (item.status == 'in_progress' || item.status == 'accepted');

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      try {
        return DateFormat('dd MMM yyyy', 'es').format(d);
      } catch (_) {
        return DateFormat('dd MMM yyyy').format(d);
      }
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;
    final style = _statusStyle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: isWide ? _buildWideLayout(context, style) : _buildNarrowLayout(context, style),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, _StatusStyle style) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLeftBlock(style)),
        const SizedBox(width: 24),
        SizedBox(width: 220, child: _buildRightBlock(context)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, _StatusStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftBlock(style),
        const SizedBox(height: 16),
        _buildRightBlock(context),
      ],
    );
  }

  Widget _buildLeftBlock(_StatusStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _statusPill(style),
            const SizedBox(width: 8),
            _typePill(),
            const SizedBox(width: 8),
            Text(
              'ID: #${item.id}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(item.createdAt),
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (item.type == UnifiedRequestType.service && (item.serviceCategory != null || item.serviceTypeName != null))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (item.serviceCategory != null)
                  _chip(item.serviceCategory!, const Color(0xFF06b6d4)),
                if (item.serviceTypeName != null)
                  _chip(item.serviceTypeName!, Colors.orange),
              ],
            ),
          ),
        _infoRow(Icons.location_on_outlined, item.type == UnifiedRequestType.store ? 'Entrega en' : 'Origen', item.location),
        if (item.type == UnifiedRequestType.store && item.storeName != null)
          _infoRow(Icons.store_outlined, 'Tienda', item.storeName!),
        if (item.providerName != null)
          _infoRow(Icons.person_outline, 'Proveedor', item.providerName!),
      ],
    );
  }

  Widget _statusPill(_StatusStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.border),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(color: style.text, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _typePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        item.type == UnifiedRequestType.service ? 'Servicio' : 'Tienda',
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRightBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.type == UnifiedRequestType.service ? 'Costo estimado' : 'Total',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.amount),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ver detalles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            if (_canTrack && onTrack != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06b6d4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tracking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StatusStyle {
  final Color text;
  final Color border;
  Color get bg => text.withOpacity(0.2);
  _StatusStyle(this.text, this.border);
}
