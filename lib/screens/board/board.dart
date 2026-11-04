import 'dart:math';

import 'package:balawish/controllers/game_controller.dart';
import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/screens/shop/shop.dart';
import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/jokers/joker_view.dart';
import 'package:balawish/widgets/game/hand_score_panel.dart';
import 'package:balawish/widgets/game/playing_card_view.dart';
import 'package:balawish/widgets/game/round_end_panel.dart';
import 'package:balawish/widgets/game/round_stats.dart';
import 'package:balawish/widgets/generic/background.dart';
import 'package:flutter/material.dart';

// Gameboard adapté au thème
class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final _controller = GameController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final run = _controller.run;
          final round = run.currentRound;

          if (run.isInShop) {
            return ShopScreen(
              run: run,
              onBuy: _controller.buyJoker,
              onSell: _controller.sellJoker,
              onMove: _controller.moveJoker,
              onContinue: _controller.nextRound,
            );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                'Manche ${run.roundNumber}',
                style: context.text.headlineSmall,
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _JokerStrip(jokers: run.jokers),
                        const SizedBox(height: 12),
                        RoundStats(run: run),
                        const SizedBox(height: 16),
                        HandScorePanel(round: round),
                        const Spacer(),
                        Image.asset('assets/enemies/${themeNotifier.value.name}/${round.enemy.picName}.png', height: 180),
                        const Spacer(),
                        _HandView(
                          round: round,
                          onCardTap: _controller.toggleSelection,
                        ),
                        const SizedBox(height: 24),
                        _ActionButtons(
                          round: round,
                          onPlay: _controller.play,
                          onDiscard: _controller.discard,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pioche : ${round.cardsInDeck} cartes',
                          style: context.text.bodySmall?.copyWith(
                            color: context.game.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!round.isPlaying)
                    Positioned.fill(
                      child: RoundEndPanel(
                        run: run,
                        onOpenShop: _controller.openShop,
                        onRestart: _controller.restart,
                        onQuit: () => Navigator.of(context).pop(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Jokers du joueur dans l'ordre d'application
class _JokerStrip extends StatelessWidget {
  const _JokerStrip({required this.jokers});

  final List<Joker> jokers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < GameRun.maxJokers; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: i < jokers.length
                  ? JokerView(
                      joker: jokers[i],
                      width: double.infinity,
                      compact: true,
                    )
                  : const SizedBox(height: 40),
            ),
          ),
      ],
    );
  }
}

// Les cartes du joueur
class _HandView extends StatelessWidget {
  const _HandView({required this.round, required this.onCardTap});

  final Round round;
  final ValueChanged<PlayingCard> onCardTap;

  static const _spacing = 4.0;
  static const _maxCardWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const slots = Round.handSize;
        final cardWidth = min(
          _maxCardWidth,
          (constraints.maxWidth - _spacing * slots) / slots,
        );

        return SizedBox(
          // Place réservée pour les cartes sélectionnées, qui se soulèvent.
          height: cardWidth * PlayingCardView.heightRatio * 1.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final card in round.hand)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _spacing / 2),
                  child: PlayingCardView(
                    card: card,
                    width: cardWidth,
                    selected: round.isSelected(card),
                    onTap: () => onCardTap(card),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Boutons Jouer et Défausser (désactivés quand l'action n'est pas possible)
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.round,
    required this.onPlay,
    required this.onDiscard,
  });

  final Round round;
  final VoidCallback onPlay;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            context,
            label: 'Jouer',
            color: game.chips,
            onPressed: round.canPlay ? onPlay : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            context,
            label: 'Défausser',
            color: game.mult,
            onPressed: round.canDiscard ? onDiscard : null,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: context.game.onAccent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: context.text.titleMedium?.copyWith(
          color: onPressed == null ? null : context.game.onAccent,
        ),
      ),
    );
  }
}
