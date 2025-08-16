import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../../ads_helper.dart';
import '../../game_state.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> items = [];
  int index = 0;
  int correct = 0;
  int? selected;
  bool finished = false;
  bool rewardedUsed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/seed/logistica.json');
    final seed = jsonDecode(raw);
    setState(() {
      items = seed['quizzes'][0]['items'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz: MRP Básico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: finished ? _buildResult(gs) : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    if (items.isEmpty) return const Center(child: CircularProgressIndicator());
    final item = items[index];
    final List opts = item['opts'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: (index + 1) / items.length),
        const SizedBox(height: 16),
        Text(item['q'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (var i = 0; i < opts.length; i++)
          RadioListTile<int>(
            title: Text(opts[i]),
            value: i,
            groupValue: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: selected == null ? null : _next,
          child: Text(index == items.length - 1 ? 'Terminar' : 'Siguiente'),
        ),
      ],
    );
  }

  void _next() {
    final item = items[index];
    if (selected == item['a']) correct++;
    selected = null;
    if (index == items.length - 1) {
      setState(() => finished = true);
    } else {
      setState(() => index++);
    }
  }

  Widget _buildResult(GameState gs) {
    final scorePct = ((correct / items.length) * 100).round();
    int materiaPrimaReward;
    if (scorePct >= 80) {
      materiaPrimaReward = 6 + (correct - 4).clamp(0, 10);
    } else if (scorePct >= 60) {
      materiaPrimaReward = 4;
    } else {
      materiaPrimaReward = 2;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resultado: $scorePct%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Has ganado Materia Prima: +$materiaPrimaReward'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            gs.addMateriaPrima(materiaPrimaReward);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Aceptar recompensa'),
        ),
        const SizedBox(height: 16),
        if (!rewardedUsed)
          OutlinedButton.icon(
            onPressed: () async {
              await AdsHelper.showRewarded((reward) {
                gs.addWip(1);
              });
              setState(() => rewardedUsed = true);
            },
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Ver anuncio para +1 WIP extra'),
          ),
      ],
    );
  }
}
