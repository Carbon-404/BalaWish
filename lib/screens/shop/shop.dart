import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/jokers/joker_view.dart';
import 'package:flutter/material.dart';

// Boutique entre deux manches : acheter, vendre et réordonner les jokers
class ShopScreen extends StatelessWidget {
  const ShopScreen({
    super.key,
    required this.run,
    required this.onBuy,
    required this.onSell,
    required this.onMove,
    required this.onContinue,
  });

  final GameRun run;
  final ValueChanged<int> onBuy;
  final ValueChanged<int> onSell;
  final void Function(int from, int to) onMove;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final offers = run.shop!.offers;
    final jokers = run.jokers;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Boutique', style: context.text.headlineSmall),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${run.coins} pièces',
                style: context.text.titleMedium?.copyWith(color: game.coins),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('OFFRES'),
              const SizedBox(height: 12),
              // Toutes les offres prennent la hauteur de la plus grande
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < offers.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _Offer(
                            joker: offers[i],
                            canBuy: run.canBuy(i),
                            onBuy: () => onBuy(i),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                'VOS JOKERS (${jokers.length}/${GameRun.maxJokers})',
              ),
              Text(
                'Maintenir déposez-le sur un autre emplacement pour le déplacer.',
                style: context.text.bodySmall?.copyWith(color: game.textMuted),
              ),
              const SizedBox(height: 12),
              _JokerGrid(jokers: jokers, onSell: onSell, onMove: onMove),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Manche ${run.roundNumber + 1}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Jokers possédés sur une grille de 3 colonnes, sans défilement
// Ordre d'application : de gauche à droite, puis ligne suivante
class _JokerGrid extends StatelessWidget {
  const _JokerGrid({
    required this.jokers,
    required this.onSell,
    required this.onMove,
  });

  final List<Joker> jokers;
  final ValueChanged<int> onSell;
  final void Function(int from, int to) onMove;

  static const _columns = 3;
  static const _emptySlotHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final rows = (GameRun.maxJokers / _columns).ceil();

    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Padding(
            padding: EdgeInsets.only(bottom: row < rows - 1 ? 8 : 0),
            // Les cartes d'une même ligne prennent la hauteur de la plus grande
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var column = 0; column < _columns; column++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _slot(context, row * _columns + column),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Un emplacement : un joker déplaçable, ou une case vide
  // Chacun accepte un joker déposé, qui prend alors sa place
  Widget _slot(BuildContext context, int index) {
    // La grille peut avoir plus de cases que de jokers autorisés
    if (index >= GameRun.maxJokers) return const SizedBox();

    final isEmpty = index >= jokers.length;
    // Déposé sur une case vide, le joker passe en dernière position
    final target = isEmpty ? jokers.length - 1 : index;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != target,
      onAcceptWithDetails: (details) => onMove(details.data, target),
      builder: (context, candidates, _) {
        final isHovered = candidates.isNotEmpty;

        if (isEmpty) return _EmptySlot(highlighted: isHovered);

        final joker = jokers[index];
        final card = JokerView(
          joker: joker,
          width: double.infinity,
          footer: TextButton(
            onPressed: () => onSell(index),
            child: Text('Vendre +${joker.sellPrice}'),
          ),
        );

        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: JokerView(joker: joker),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: card),
          child: AnimatedScale(
            scale: isHovered ? 1.05 : 1,
            duration: const Duration(milliseconds: 120),
            child: card,
          ),
        );
      },
    );
  }
}

// Case de la grille sans joker
class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.highlighted});

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Container(
      constraints: const BoxConstraints(
        minHeight: _JokerGrid._emptySlotHeight,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? game.selection : game.panelBorder,
          width: highlighted ? 2 : 1,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.text.labelLarge?.copyWith(
        color: context.game.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

// Une offre : le joker et son bouton d'achat, ou un emplacement vide une fois acheté
class _Offer extends StatelessWidget {
  const _Offer({
    required this.joker,
    required this.canBuy,
    required this.onBuy,
  });

  final Joker? joker;
  final bool canBuy;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final offer = joker;
    if (offer == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'Acheté',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.game.textMuted),
        ),
      );
    }
    return JokerView(
      joker: offer,
      width: double.infinity,
      footer: FilledButton(
        onPressed: canBuy ? onBuy : null,
        child: Text('${offer.price} pièces'),
      ),
    );
  }
}
