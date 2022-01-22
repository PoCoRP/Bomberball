# Projet Bomberball - POCO - README
## Godot
### Version

&ensp;&ensp;&ensp;&ensp;La version de Godot à utiliser est la version standard 3.4.2 téléchargeable ici pour Linux, macOS et Windows : https://godotengine.org/download

### Première ouverture du projet

#### Touches
&ensp;&ensp;&ensp;&ensp;Si les contrôles ne sont pas bien paramétrés, vous devez aller dans : Project ->  Project Settings ->  Input Map ->  Project Settings



- Joueur 1
    - haut : up_1
    - bas : down_1
    - droite : right_1
    - gauche : left_1
    - poser bombe : bomb_1


- Joueur 2
    - haut : up_2
    - bas : down_2
    - droite : right_2
    - gauche : left_2
    - poser bombe : bomb_2


- Joueur 3
    - haut : up_3
    - bas : down_3
    - droite : right_3
    - gauche : left_3
    - poser bombe : bomb_3


- Joueur 4
    - haut : up_4
    - bas : down_4
    - droite : right_4
    - gauche : left_4
    - poser bombe : bomb_4


#### Sons
&ensp;&ensp;&ensp;&ensp;Si vous avez un problème de son qui se répète quand vous exécutez le projet dans Godot, il faut cliquer sur Import en haut du menu de gauche et aller dans FileSystem (barre de gauche aussi)  -> ressources -> Musics, sélectionner tous les .mp3 sauf les 3 suivants :
            
- Musique Menu.mp3
- Musique Multijoueur.mp3
- Musique Solo.mp3
            
Ensuite, Décochez Loop

Et enfin, cliquez sur Reimport(*) dans l'onglet Import.



## Description
### Bonus
Les bonus sont communs aux parties multijoueurs et solo. En voici une liste :

- Bombe : Rouge - Permet de poser plus de bombe en même temps

- Portée : Orange - Augmente le rayon de déflagration de la bombe du joueur concerné

- Pousser : Rose - Rend possible de pousser toutes les bombes du joueur concerné

- Vitesse : Bleu - Augmente la vitesse du joueur

- GodMode : Arc-en-ciel - Rend invulnérable aux bombes pendant 5 secondes
       
>Les bombes explosent en croix et même en traversant les murs et détruisent les murs cassables.


### Solo
#### Touches

Les contrôles du joueur 1 sont sur Z Q S D et Espace.

- **Z** : Aller vers le haut

- **Q** : Aller vers la gauche

- **S** : Aller vers le bas

- **D** : Aller vers la droite

- **Espace** : Poser une bombe
           
#### Fonctionnement
            
Le but du joueur est de rejoindre la sortie sans mourir.

Le joueur a 3 vies donc il peut peut se faire toucher par ses propres bombes 2 fois sans mourir mais la troisième sera fatale. Par contre un seul contact avec un ennemi le tuera instantanément.

Le solo a un bonus supplémentaire : Le bonus lumière qui illumine le labyrinthe un court instant. Il est de couleur jaune.


### Multijoueur

#### Touches
**- Pour 2 joueurs**

&ensp;&ensp;&ensp;&ensp;Les joueurs jouent tous les deux sur le clavier.

Les contrôles sur le clavier sont sur Z, Q, S, D et Espace pour la bombe et pour le joueur 2, les flèches directionnelles et Ctrl pour la bombe.

**- Pour 3 joueurs**

&ensp;&ensp;&ensp;&ensp;Les joueurs peuvent tous les 3 jouer sur le clavier ou bien à deux sur le clavier et le troisième joueur à la manette.

Les contrôles sur le clavier sont sur Z, Q, S, D et Espace, les flèches directionnelles et Ctrl et le joueur 3 se déplace avec O, K, L, M et N pour poser une bombe.

Les contrôles sur la manette sont les joysticks et les triggers.

**- Pour 4 joueurs**

&ensp;&ensp;&ensp;&ensp;Deux joueurs sont sur le clavier et les deux autres sur une manette. 
                
> /!\ Comme expliqué plus haut il est toujours possible de redéfinir les touches de chacun des joueurs depuis Godot /!\
            
#### Fonctionnement
            
Il peut être à 2, 3 ou 4 joueurs en local.

Chaque joueur à une couleur différente et n'a qu'une vie.

Le but est d'être le dernier survivant. Pour cela il faut réussir à toucher les autres joueurs avec la déflagration de ses bombes tout en évitant de se faire toucher.
