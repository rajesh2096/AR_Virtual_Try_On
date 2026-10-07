import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../models/tryon_session_model.dart';
import '../../services/tryon_service.dart';

class TryonHistoryScreen extends StatefulWidget {
  const TryonHistoryScreen({super.key});

  @override
  State<TryonHistoryScreen> createState() => _TryonHistoryScreenState();
}

class _TryonHistoryScreenState extends State<TryonHistoryScreen> {
  List<TryonSessionModel> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await TryonService.getHistory();
      if (mounted) {
        setState(() {
          _history = list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Try-On History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHistory,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('No Try-On History Yet', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Start a try-on session to see your activity here.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (ctx, index) {
          final item = _history[index];
          final dateStr = item.createdAt != null ? DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt!) : '';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Person Image thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 60,
                    height: 80,
                    color: AppColors.surface,
                    child: item.personImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.personImageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.person, color: AppColors.textMuted),
                          )
                        : const Icon(Icons.person, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Session #${item.id}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: const TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Garment: ${item.garment?.name ?? 'ID #${item.garmentId}'}',
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
