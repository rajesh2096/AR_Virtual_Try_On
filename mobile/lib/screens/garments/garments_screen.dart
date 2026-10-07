import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../models/garment_model.dart';
import '../../services/garment_service.dart';
import 'upload_garment_screen.dart';

class GarmentsScreen extends StatefulWidget {
  final bool selectMode;
  final Function(GarmentModel)? onSelect;

  const GarmentsScreen({
    super.key,
    this.selectMode = false,
    this.onSelect,
  });

  @override
  State<GarmentsScreen> createState() => _GarmentsScreenState();
}

class _GarmentsScreenState extends State<GarmentsScreen> {
  List<GarmentModel> _garments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGarments();
  }

  Future<void> _loadGarments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await GarmentService.getGarments();
      if (mounted) {
        setState(() {
          _garments = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteGarment(GarmentModel garment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Garment', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure you want to delete "${garment.name}"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GarmentService.deleteGarment(garment.id);
        _loadGarments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Garment deleted'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.selectMode ? 'Select a Dress' : 'My Wardrobe',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _loadGarments,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UploadGarmentScreen()),
          );
          if (res != null) {
            _loadGarments();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        label: const Text('Add Garment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Could not load garments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadGarments,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (_garments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.checkroom_outlined, size: 64, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Garments Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Capture or upload clothing photos from your device to start your virtual wardrobe.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGarments,
      color: AppColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _garments.length,
        itemBuilder: (ctx, index) {
          final garment = _garments[index];
          return _buildGarmentCard(garment);
        },
      ),
    );
  }

  Widget _buildGarmentCard(GarmentModel garment) {
    return GestureDetector(
      onTap: () {
        if (widget.selectMode) {
          if (widget.onSelect != null) {
            widget.onSelect!(garment);
          }
          Navigator.of(context).pop(garment);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  garment.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: garment.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primaryLight)),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                          ),
                        )
                      : Container(color: AppColors.surface, child: const Icon(Icons.image, color: AppColors.textMuted)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        onPressed: () => _deleteGarment(garment),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        garment.category,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: #${garment.id}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
