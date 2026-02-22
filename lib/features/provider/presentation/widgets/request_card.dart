import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/express_request.dart';

class RequestCard extends StatelessWidget {
  final ExpressRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const RequestCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.slate900,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (request.categoryIcon != null)
                        Text(request.categoryIcon!, style: const TextStyle(fontSize: 12)),
                      if (request.categoryIcon != null)
                        const SizedBox(width: 4),
                      Text(
                        request.serviceName ?? request.categoryName ?? 'Servicio',
                        style: TextStyle(
                          color: _getUrgencyColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(request.proposedPrice),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Origin
            Row(
              children: [
                const Icon(Icons.my_location, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Origen: ${request.originAddress}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Connector line
            Container(
              margin: const EdgeInsets.only(left: 7),
              height: 20,
              width: 2,
              color: Colors.white10,
            ),

            // Destination
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Destino: ${request.destAddress}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Additional info
            if (request.distanceKm != '0' || request.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    if (request.distanceKm != '0') ...[
                      const Icon(Icons.route, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${request.distanceKm} km',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                    if (request.distanceKm != '0' && request.notes != null)
                      const SizedBox(width: 16),
                    if (request.notes != null) ...[
                      const Icon(Icons.notes, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          request.notes!,
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Action buttons (only show if callbacks provided)
            if (onAccept != null || onReject != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: const Text('Rechazar'),
                      ),
                    ),
                  if (onReject != null && onAccept != null)
                    const SizedBox(width: 12),
                  if (onAccept != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Aceptar'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor() {
    if (request.isUrgent) {
      return Colors.orange;
    }
    return Colors.blue;
  }
}
