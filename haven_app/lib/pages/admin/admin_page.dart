import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _secretCtrl = TextEditingController();
  List<Map<String, dynamic>> _requests = [];
  bool _loading = false;
  bool _authenticated = false;
  String? _error;

  @override
  void dispose() {
    _secretCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService().getAdminDeletionRequests(secret: _secretCtrl.text.trim());
      setState(() { _requests = data; _authenticated = true; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Secret invalide ou erreur serveur.'; _loading = false; });
    }
  }

  Future<void> _process(String id, String action) async {
    try {
      await ApiService().processAdminDeletion(
        secret: _secretCtrl.text.trim(), id: id, action: action);
      _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du traitement.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.racingGreen),
                    ),
                    const Text('Administration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.racingGreen)),
                  ],
                ),
              ),
              Expanded(
                child: _authenticated ? _buildRequestList() : _buildAuthForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings_outlined, size: 56, color: AppColors.corduroy),
          const SizedBox(height: 20),
          const Text('Accès administrateur',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.racingGreen)),
          const SizedBox(height: 24),
          TextField(
            controller: _secretCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'ADMIN_SECRET',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key_outlined),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.delButton, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eucalyptus,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Accéder', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.eucalyptus,
      child: _requests.isEmpty
          ? const Center(
              child: Text('Aucune demande de suppression en attente.',
                style: TextStyle(fontSize: 14, color: AppColors.corduroy),
                textAlign: TextAlign.center))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final req = _requests[i];
                final user = req['user'] as Map<String, dynamic>?;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?['name'] as String? ?? '—',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.racingGreen)),
                      const SizedBox(height: 4),
                      Text(user?['email'] as String? ?? '—',
                        style: const TextStyle(fontSize: 13, color: AppColors.corduroy)),
                      Text('${user?['schoolCode']} · ${user?['className']}',
                        style: const TextStyle(fontSize: 12, color: AppColors.edward)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _process(req['id'] as String, 'reject'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.corduroy),
                              child: const Text('Refuser'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _process(req['id'] as String, 'approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.delButton,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Supprimer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
