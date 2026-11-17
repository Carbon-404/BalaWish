# BalaWish

Jeu de cartes solo pour Android, inspiré de *Balatro* : on enchaîne des manches en jouant des mains de poker pour battre un score imposé (la **blinde**), et on achète des **jokers** entre les manches pour faire grimper ses scores.

Projet individuel « Poker Roguelike » — Développement mobile, Flutter.

---

## Lancer le projet

**Prérequis**

- Flutter **3.47** (canal stable) ou plus récent
- Android SDK avec un émulateur récent (testé pour **SDK 34 / 35**)
- JDK **17 ou plus** (exigé par Gradle 9)

**Commandes** (depuis la racine du projet)

```bash
flutter pub get     # récupère les dépendances listées dans pubspec.yaml
flutter run         # lance l'application sur l'émulateur ou l'appareil connecté
flutter test        # lance les tests unitaires
```

**Dépendances**

| Paquet | Usage |
|---|---|
| `google_fonts` | Polices propres à chaque thème |
| `shared_preferences` | Sauvegarde des statistiques sur le téléphone |

**Configuration Android** : Gradle 9.8.2, Android Gradle Plugin 9.5.0, Kotlin 2.3.20.

> **Note Windows** : `android/gradle.properties` contient `kotlin.incremental=false`. Sans cette ligne, la compilation du plugin `shared_preferences` échoue quand le projet et le cache Flutter (`pub cache`) sont sur deux disques différents (ex. `E:` et `C:`).

---

## Règles du jeu

### Déroulement d'une manche

1. La pioche de 52 cartes est mélangée ; le nombre de mains et de défausses est fixé.
2. Le joueur a toujours **7 cartes en main** (moins si la pioche est vide).
3. Il sélectionne **jusqu'à 5 cartes**, puis choisit :
   - **Jouer** : la main de poker est évaluée, ses points s'ajoutent au score, une main est consommée, et les cartes jouées sont remplacées ;
   - **Défausser** : les cartes sont remplacées sans marquer, une défausse est consommée (impossible quand il n'en reste plus).
4. La manche est **gagnée dès que le score atteint la blinde**, et **perdue** si les mains (ou les cartes) viennent à manquer avant.

Le nombre de mains augmente avec la blinde (4 au départ, jusqu'à 8), et chaque manche donne 3 défausses.

### Décompte des points

Score d'une main = **jetons × multi**, calculé dans l'ordre du sujet :

1. Le **type de main** donne des jetons et un multi de base (tableau ci-dessous) ;
2. Chaque carte **qui forme la main**, de gauche à droite, ajoute sa valeur en jetons (2 à 10 : leur valeur, figures : 10, as : 11). Les jokers liés à une carte s'appliquent à ce moment ;
3. Les **jokers** appliquent ensuite leurs effets, **de gauche à droite** : leur ordre compte.

| Main | Jetons | Multi |
|---|---|---|
| Carte haute | 5 | 1 |
| Paire | 10 | 2 |
| Double paire | 20 | 2 |
| Brelan | 30 | 3 |
| Suite | 30 | 4 |
| Couleur | 35 | 4 |
| Main pleine | 40 | 4 |
| Carré | 60 | 7 |
| Quinte flush | 100 | 8 |
| Quinte flush royale | 100 | 10 |

L'as compte en haut (10-V-D-R-A) comme en bas (A-2-3-4-5) dans les suites.

### Boutique et jokers

Après chaque manche gagnée, le joueur reçoit des pièces : **3 + 1 par main non utilisée**, plus les bonus des jokers. Dans la boutique, il peut :

- **acheter** un joker parmi 3 offres tirées au hasard (jamais un joker déjà possédé) ;
- **vendre** un joker pour récupérer des pièces ;
- **réordonner** ses jokers (appui long puis glisser-déposer).

On ne peut pas détenir plus de **5 jokers**. Le prix dépend de la rareté :

| Rareté | Achat | Revente |
|---|---|---|
| Commun | 4 | 2 |
| Peu commun | 6 | 3 |
| Rare | 8 | 4 |
| Légendaire | 12 | 6 |

**Jokers disponibles**

| Joker | Effet | Rareté |
|---|---|---|
| Joker | +4 multi | Commun |
| Joker Paire | +20 jetons si la main contient une paire | Commun |
| Joker Brelan | +12 multi si la main contient un brelan | Peu commun |
| Joker Suite | +8 multi si une suite est jouée | Peu commun |
| Joker Couleur | +10 multi si une couleur est jouée | Peu commun |
| Joker Cœur / Carreau / Pique / Trèfle | +3 multi par carte de cette enseigne qui marque | Commun |
| Joker Économe | +1 pièce en fin de manche | Commun |
| Joker Fou | ×2 multi (à placer après les jokers qui ajoutent du multi) | Rare |

---

## Améliorations réalisées

### Ennemis et blindes boss

Chaque manche oppose le joueur à un **ennemi du casino**, dont la blinde est le score à atteindre. Un appui sur son portrait affiche sa description. Certains ennemis sont des **boss** qui ajoutent une contrainte :

| Manche | Ennemi | Blinde | Effet de boss |
|---|---|---|---|
| 1 | Jeton Filou | 300 | — |
| 2 | Dés Jumeaux | 450 | — |
| 3 | **Dame de Pique** | 800 | Les cartes ♠ ne marquent pas |
| 4 | Valet Tricheur | 1 200 | — |
| 5 | Bandit Manchot | 1 600 | — |
| 6 | **Baron Roulette** | 2 500 | Une enseigne tirée au hasard ne marque pas, à chaque main |
| 7 | Croupier Fantôme | 3 500 | — |
| 8 | **Le Banquier** | 5 000 | Une seule défausse, mais récompense en pièces doublée |
| 9 | **La Maison** | 8 000 | Désactive le joker le plus à gauche |

Les cartes neutralisées par un boss sont grisées dans la main.

### Deux modes de jeu

- **Mode Histoire** : les 9 ennemis dans l'ordre ; la partie est gagnée en battant La Maison.
- **Mode Arcade** : une partie **sans fin**. Les 9 premières manches sont celles de l'histoire, puis les ennemis reviennent en boucle avec une blinde qui augmente de 25 % à chaque manche. La partie ne s'arrête qu'à la défaite.

### Statistiques

Sauvegardées sur le téléphone et conservées entre deux lancements (écran **Stats** du menu) :

- nombre de mains jouées pour chaque type de main ;
- nombre de parties jouées ;
- meilleur et pire score d'une partie (toutes manches cumulées) ;
- manche maximale atteinte en mode histoire, et record du mode arcade.

### Thèmes

Trois thèmes visuels au choix dans les **Paramètres** (icône en haut à droite du menu) : **Casino** (tapis vert), **Néon** (contours lumineux) et **Minimal** (sobre). Chaque thème a ses couleurs, ses polices et ses portraits d'ennemis ; le changement est animé.

### Animations

Éventail de cartes animé sur l'écran d'accueil, cartes sélectionnées qui se soulèvent, transition animée entre les thèmes.

---

## Choix et écarts par rapport au sujet

- **Fin de manche anticipée** : la manche s'arrête dès que la blinde est atteinte (comme dans Balatro) plutôt qu'après la dernière main ; les mains non jouées rapportent 1 pièce chacune.
- **Cartes dessinées par le code** : les cartes sont affichées avec leur rang et leur enseigne aux couleurs du thème, plutôt qu'avec les images fournies, pour s'adapter aux trois thèmes.
- **Joker Doubleur** : non implémenté. Il demande de mémoriser l'effet de chaque joker séparément, ce que le calcul actuel ne fait pas encore.
- **Thème** : le thème choisi n'est pas conservé après la fermeture de l'application.

---

## Organisation du code

La logique du jeu (`lib/models`) est écrite en Dart pur, sans dépendance à Flutter, ce qui permet de la tester indépendamment de l'interface.

```
lib/
├── main.dart                  Point d'entrée : charge les statistiques puis lance l'app
├── controllers/               Lien entre le modèle et l'interface (ChangeNotifier)
│   ├── game_controller.dart     Actions du joueur pendant une partie
│   └── stats_controller.dart    Statistiques partagées et sauvegardées
├── models/                    Logique du jeu
│   ├── cards/                   Cartes (rang, enseigne) et pioche
│   ├── calculator/              Évaluation des mains de poker et calcul du score
│   ├── enemy/                   Ennemis et effets de boss
│   ├── game/                    Partie (classe abstraite Game), modes histoire et arcade, manche
│   ├── jokers/                  Classe Joker, types d'effets et catalogue
│   ├── shop/                    Offres de la boutique
│   └── stats/                   Statistiques du joueur (sérialisées en JSON)
├── services/storage.dart      Sauvegarde sur le téléphone (shared_preferences)
├── screens/                   Écrans : menu, plateau de jeu, boutique, stats, paramètres
├── widgets/                   Composants réutilisables : cartes, jokers, ennemis, panneaux
└── theme/theme.dart           Les trois thèmes et leurs couleurs de jeu
assets/enemies/<thème>/        Portraits des ennemis pour chaque thème
test/                          Tests unitaires
```

**Ajouter un joker** : une entrée dans `lib/models/jokers/joker_list.dart` (en réutilisant un type d'effet de `joker_types.dart`). Un effet inédit = une nouvelle classe qui hérite de `Joker`.

**Changer les prix** : les valeurs de l'enum `JokerRarity` dans `lib/models/jokers/joker.dart`.
