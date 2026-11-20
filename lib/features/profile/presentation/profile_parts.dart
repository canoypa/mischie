import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';

class CompactChip extends StatelessWidget {
  const CompactChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class RelationshipChip extends StatelessWidget {
  const RelationshipChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      side: BorderSide.none,
    );
  }
}

class RoleChip extends StatelessWidget {
  const RoleChip({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(role.color);
    return Chip(
      avatar: role.iconUrl != null
          ? CircleAvatar(
              radius: 8,
              backgroundImage: CachedNetworkImageProvider(
                role.iconUrl!,
                cacheManager: MediaCacheManager.instance,
              ),
            )
          : null,
      label: Text(role.name),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      side: color != null ? BorderSide(color: color) : null,
    );
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null) return null;
    var value = hex.trim();
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 3) {
      value = value.split('').map((c) => '$c$c').join();
    }
    if (value.length != 6) return null;
    final intValue = int.tryParse(value, radix: 16);
    if (intValue == null) return null;
    return Color(0xFF000000 | intValue);
  }
}

class StatColumn extends StatelessWidget {
  const StatColumn({
    super.key,
    required this.count,
    required this.label,
    this.onTap,
  });

  final int? count;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count?.toString() ?? '-',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}

class MetaRow extends StatelessWidget {
  const MetaRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
