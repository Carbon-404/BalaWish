enum Enemy {
  maliciousToken(1, 'Jeton Filou', 'jeton_filou', 300, 'Un petit jeton masqué qui traîne dans le hall et chipe les pièces oubliées sur les tables. Il est plus agaçant que dangereux, mais c’est lui qui annonce votre arrivée au reste du casino.', '', false),
  twinDices(2, 'Dés Jumeaux', 'des_jumeaux', 450, 'Deux frères inséparables : l’un est toujours grincheux, l’autre rigole de tout. Ils ne s’accordent sur rien, sauf pour vous barrer la route.', '', false),
  spikeQueen(3, 'Dame de Pique', 'dame_de_pique', 800, 'La reine du hall règne sur les tables d’une main gantée. Les piques lui obéissent : face à elle, ils ne vous rapportent plus rien.', '', true),
  cheatingValet(4, 'Valet Tricheur', 'valet_tricheur', 1200, 'Un valet élégant qui cache toujours une carte dans sa manche. Il sourit à chaque défausse, parce qu’il en profite pour vous faire les poches.', 'Les cartes ♠ ne rapportent pas de jetons', true),
  slotMachine(5, 'Bandit Manchot', 'bandit_manchot', 1600, 'Une vieille machine à sous qui ne s’est jamais arrêtée de tourner. Elle n’a qu’un bras, mais ses rouleaux décident de votre anenir.', '', false),
  baronRoulette(6, 'Baron Roulette', 'baron_roulette', 2500, 'Un aristocrate au monocle dont le ventre tourne comme une roulette. Il adore les paris et peut changer le cours de la partie.', 'Une couleur de cartes interdite, tirée au début de chaque main', true),
  ghostCroupier(7, 'Croupier Fantôme', 'croupier_fantome', 3500, 'Il distribue encore les cartes à une table qui a fermé il y a cent ans. Personne ne sait ce qu’il cache sous sa visière, ni quelle carte il vient de retourner.', '', false),
  theBanker(8, 'Le Banquier', 'banquier', 5000, 'Le coffre-fort vivant qui garde les dettes de tous les joueurs. Il est avare de défausses, mais quand il perd, ses pièces débordent.', 'Une seule défausse, mais une récompense en pièces doublée', true),
  theHouse(9, 'La Maison', 'la_maison', 8000, 'Le casino lui-même, qui vous observe de son œil unique depuis le premier jeton. On dit que La Maison gagne toujours ; c’est à vous de prouver le contraire.', 'Désactive votre joker le plus à gauche', true);

  const Enemy(this.order, this.name, this.picName, this.score, this.description, this.effectDescription, this.isBoss);

  final int order;
  final String name;
  final String picName;
  final int score;
  final String description;
  final String effectDescription;
  final bool isBoss;
}