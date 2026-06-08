import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:katalog/config/api_config.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Map<String, dynamic>? _panelBagus;
  Map<String, dynamic>? _panelJelek;
  int? _latencyBagus;
  int? _latencyJelek;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _fetchPanelBagus(),
        _fetchPanelJelek(),
      ]);
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchPanelBagus() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(const Duration(seconds: 10));
      stopwatch.stop();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _panelBagus = data['data']['panel_bagus'];
          });
        }
      }
      _latencyBagus = stopwatch.elapsedMilliseconds;
    } catch (_) {
      setState(() {
        _panelBagus = {'status': 'gagal tersambung'};
        _latencyBagus = null;
      });
    }
  }

  Future<void> _fetchPanelJelek() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.imageBaseUrl}/health'))
          .timeout(const Duration(seconds: 10));
      stopwatch.stop();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _panelJelek = data['data'];
          });
        }
      }
      _latencyJelek = stopwatch.elapsedMilliseconds;
    } catch (_) {
      setState(() {
        _panelJelek = {'status': 'gagal tersambung'};
        _latencyJelek = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Server'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchAll, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _cardPanel('🧠 Otak Utama', _panelBagus, _latencyBagus),
                    const SizedBox(height: 12),
                    _cardPanel('🗄️ Otak Penyimpanan Gambar', _panelJelek, _latencyJelek),
                    if (_panelBagus != null && _panelBagus!['system'] != null) ...[
                      const SizedBox(height: 12),
                      _cardSpec('🖥️ CPU Otak Utama', _panelBagus!['system']['cpu']),
                      const SizedBox(height: 12),
                      _cardSpec('💾 RAM Otak Utama', _panelBagus!['system']['ram']),
                      const SizedBox(height: 12),
                      _cardSpec('📦 Storage Otak Utama', _panelBagus!['system']['storage']),
                    ],
                    if (_panelJelek != null && _panelJelek!['system'] != null) ...[
                      const SizedBox(height: 12),
                      _cardSpec('🖥️ CPU Otak Penyimpanan', _panelJelek!['system']['cpu']),
                      const SizedBox(height: 12),
                      _cardSpec('💾 RAM Otak Penyimpanan', _panelJelek!['system']['ram']),
                      const SizedBox(height: 12),
                      _cardSpec('📦 Storage Otak Penyimpanan', _panelJelek!['system']['storage']),
                      const SizedBox(height: 12),
                      _cardGambar(_panelJelek!['images']),
                    ],
                  ],
                ),
    );
  }

  Widget _cardPanel(String title, Map<String, dynamic>? data, int? latency) {
    final online = data != null && data['status'] == 'running';
    return Card(
      color: online ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: online ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    online ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (online) ...[
              const SizedBox(height: 8),
              _row('Versi', data!['version']?.toString() ?? '?'),
              _row('Uptime', data['uptime']?.toString() ?? '?'),
              _row('Latensi', latency != null ? '$latency ms' : '?'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cardSpec(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();
    final items = <MapEntry<String, String>>[];
    if (data['model'] != null) items.add(MapEntry('Model', data['model'].toString()));
    if (data['cores'] != null) items.add(MapEntry('Core', data['cores'].toString()));
    if (data['usage'] != null) items.add(MapEntry('Usage', data['usage'].toString()));
    if (data['total'] != null) items.add(MapEntry('Total', data['total'].toString()));
    if (data['used'] != null) items.add(MapEntry('Used', data['used'].toString()));
    if (data['free'] != null) items.add(MapEntry('Free', data['free'].toString()));
    if (data['usagePercent'] != null) items.add(MapEntry('Usage %', data['usagePercent'].toString()));
    if (items.isEmpty) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((e) => _row(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _cardGambar(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🖼️ Gambar Tersimpan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _row('Jumlah', '${data['count'] ?? '?'} file'),
            _row('Path', data['path']?.toString() ?? '?'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
