import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../ads_helper.dart';
import '../../game_state.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});
  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    _banner = AdsHelper.createBanner(() => setState(() {}));
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Fábrica de Logística')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 12, runSpacing: 8, children: [
            _chip('Materia Prima', gs.materiaPrima),
            _chip('WIP', gs.wip),
            _chip('Producto Terminado', gs.productoTerminado),
            _chip('Certificación', gs.certificacion),
          ]),
          const SizedBox(height: 16),
          const Text('Hitos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Hito 1 — MRP básico'),
              subtitle: const Text('Requisito: 12 MP y 1 WIP'),
              trailing: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/quiz'),
                child: const Text('Jugar Quiz'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              final gs = context.read<GameState>();
              if (gs.canShowInterstitial()) {
                await AdsHelper.showInterstitialIfAvailable(() {
                  gs.markInterstitialShown();
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progreso guardado (demo).')),
              );
            },
            icon: const Icon(Icons.emoji_events_outlined),
            label: const Text('Simular completar hito (demo)'),
          ),
          const Spacer(),
          if (_banner != null)
            SizedBox(
              height: _banner!.size.height.toDouble(),
              width: _banner!.size.width.toDouble(),
              child: AdWidget(ad: _banner!),
            ),
        ]),
      ),
    );
  }

  Widget _chip(String label, int value) =>
      Chip(label: Text('$label: $value'), avatar: const Icon(Icons.inventory_2_outlined));
}
