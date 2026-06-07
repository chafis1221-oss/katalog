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
          _panelBagus = data['data']['panel_bagus'];
        }
      }
      _latencyBagus = stopwatch.elapsedMilliseconds;
    } catch (_) {
      _panelBagus = {'status': 'gagal tersambung'};
      _latencyBagus = null;
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
          _panelJelek = data['data'];
        }
      }
      _latencyJelek = stopwatch.elapsedMilliseconds;
    } catch (_) {
      _panelJelek = {'status': 'gagal tersambung'};
      _latencyJelek = null;
    }
  }

  // ✅ Fungsi ping khusus untuk test latency saja
  Future<void> _pingTest() async {
    setState(() {
      _latencyBagus = null;
      _latencyJelek = null;
    });

    // Ping Panel Bagus
    final sw1 = Stopwatch()..start();
    try {
      await http.get(Uri.parse(ApiConfig.healthUrl)).timeout(const Duration(seconds: 5));
      _latencyBagus = sw1.elapsedMilliseconds;
    } catch (_) {
      _latencyBagus = null;
    }

    // Ping Panel Jelek
    final sw2 = Stopwatch()..start();
    try {
      await http.get(Uri.parse('${ApiConfig.imageBaseUrl}/health')).timeout(const Duration(seconds: 5));
      _latencyJelek = sw2.elapsedMilliseconds;
    } catch (_) {
      _latencyJelek = null;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Server'),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed),
            tooltip: 'Ping Test',
            onPressed: _pingTest,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchAll, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPanelCard('🧠 Otak Utama', _panelBagus, _latencyBagus),
                      const SizedBox(height: 12),
                      _buildPanelCard('🗄️ Otak Penyimpanan Gambar', _panelJelek, _latencyJelek),
                      const SizedBox(height: 12),
                      if (_panelBagus != null && _panelBagus!['status'] != 'gagal tersambung') ...[
                        _buildSpecCard('🖥️ CPU Otak Utama', _panelBagus!['system']?['cpu']),
                        const SizedBox(height: 12),
                        _buildSpecCard('💾 RAM Otak Utama', _panelBagus!['system']?['ram']),
                        const SizedBox(height: 12),
                        _buildSpecCard('📦 Storage Otak Utama', _panelBagus!['system']?['storage']),
                        const SizedBox(height: 12),
                        _buildCard('🗄️ Database', [
                          _row('Status', _panelBagus!['database']?['status'] ?? '?'),
                          _row('Ukuran', _panelBagus!['database']?['size'] ?? '?'),
                        ]),
                      ],
                      if (_panelJelek != null && _panelJelek!['status'] != 'gagal tersambung') ...[
                        const SizedBox(height: 12),
                        _buildSpecCard('🖥️ CPU Otak Penyimpanan', _panelJelek!['system']?['cpu']),
                        const SizedBox(height: 12),
                        _buildSpecCard('💾 RAM Otak Penyimpanan', _panelJelek!['system']?['ram']),
                        const SizedBox(height: 12),
                        _buildSpecCard('📦 Storage Otak Penyimpanan', _panelJelek!['system']?['storage']),
                        const SizedBox(height: 12),
                        _buildCard('🖼️ Gambar Tersimpan', [
                          _row('Jumlah', '${_panelJelek!['images']?['count'] ?? '?'} file'),
                          _row('Path', _panelJelek!['images']?['path'] ?? '?'),
                        ]),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildPanelCard(String title, Map<String, dynamic>? data, int? latency) {
    final isRunning = data != null && data['status'] != 'gagal tersambung';
    return Card(
      color: isRunning ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRunning ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isRunning ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (isRunning) ...[
              const SizedBox(height: 8),
              _row('Versi', data!['version'] ?? '?'),
              _row('Uptime', data['uptime'] ?? '?'),
              _row('Latensi', latency != null ? '$latency ms' : 'Gagal'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecCard(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();
    return _buildCard(title, [
      if (data['model'] != null) _row('Model', data['model']),
      if (data['cores'] != null) _row('Core', '${data['cores']}'),
      if (data['usage'] != null) _row('Usage', data['usage']),
      if (data['total'] != null) _row('Total', data['total']),
      if (data['used'] != null) _row('Used', data['used']),
      if (data['free'] != null) _row('Free', data['free']),
      if (data['usagePercent'] != null) _row('Usage %', data['usagePercent']),
    ]);
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
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
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
