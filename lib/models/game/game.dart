import 'package:balawish/models/cards/number_card.dart';
import 'package:balawish/models/cards/card.dart';
import 'package:balawish/models/cards/jack_card.dart';
import 'package:balawish/models/cards/queen_card.dart';
import 'package:balawish/models/cards/king_card.dart';


class Game {
  List<Card> pile = [];
  List<Card> discardPile = [];
  List<Card> playerHand = [];
  int playerHandLength = 7;
  int round = 0;
  int maxRound=-1;
  int playerScore = 0;
  int scoreToReach;

  Game(this.scoreToReach){
    for(var color in Color.values){
      for(int i =1; i <11; i++){
        pile.add(NumberCard(color, i));
      }
      pile.add(JackCard(color));
      pile.add(QueenCard(color));
      pile.add(KingCard(color));
    }

    pile.shuffle();
  }

  void fillPlayerHand(){
    int cardsToPick = playerHandLength-playerHand.length;
    for(int i = 0; i < cardsToPick; i++){
      playerHand.add(pile.removeLast());
    }
  }

}