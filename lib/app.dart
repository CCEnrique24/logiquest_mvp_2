import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'features/lobby/lobby_screen.dart';
import 'features/quiz/quiz_screen.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..loadSeed(),
      child: MaterialApp(
        title: 'LogiQuest MVP',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const LobbyScreen(),
          '/quiz': (_) => const QuizScreen(),
        },
      ),
    );
  }
}
