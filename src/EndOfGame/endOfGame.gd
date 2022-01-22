extends Node

# Score du joueur mis à jour au fur et à mesure de la partie
var score = 0
# Stockage des noms des couleurs des joueurs
var colors = ["BLUE", "YELLOW", "RED", "GREEN"]

# Tableau des textes de victoire en solo
var victoryTexts = ["NICE JOB !",
					"CONGRATULATIONS !",
					"LEVEL CLEARED !",
					"YOU WIN !",
					"GG WP",
					"MAYBE THIS ONE WAS TOO EASY FOR YOU"
					]

# Tableau des textes de défaite en solo
var lostTexts = ["BETTER LUCK NEXT TIME",
				"IT WAS PAINFUL TO WATCH",
				"TRY NOT DYING NEXT TIME",
				"TOO BAD",
				"YOU LOST",
				"GAME OVER"
				]

# Tableau des textes de fin de partie (victoire) en multijoueur
var multiEndTexts = ["{color} IS THE BEST",
					"GG WP {color}",
					"{color} IS JUST TOO GOOD !",
					"ANOTHER VICTORY FOR {color}",
					"{color} WINS !",
					"{color} IS JUST BUILT DIFFERENT",
					"YOU DID WELL BUT {color} DID BETTER",
					"#{color}2022"]

# Tableau des textes de fin de partie en multijoueur en cas d'égalité
var multiDrawEndTexts = ["YOU ARE ALL EQUALLY BAD",
						"EVERYBODY LOST :)",
						"DRAW !",
						"NO ONE WINS"
						]

onready var rng = RandomNumberGenerator.new()

# Fonction appelée quand le node entre pour la première fois sur la scène
func _ready():
	rng.randomize()
	$nextLevel/Retry.hide() # Au début on cache le menu de fin de niveau

# Fonction lancée à chaque frame du jeu
func _process(_delta):
	if Input.is_physical_key_pressed(KEY_SPACE):
		_on_NextLevelButton_pressed();

# Pour donner un score au joueur
func set_score(player_score):
	score = player_score

# Fonction appelée lors de la victoire du joueur
func _on_Player_Victory():
	var txt = victoryTexts[rng.randi_range(0,victoryTexts.size()-1)]
	$nextLevel/Retry/ScoreLabel.text = "SCORE :\n{score}".format({ "score" : str(score)}) # On affiche le score
	$nextLevel/Retry/MessageLabel.text = txt # On signale au joueur qu'il a gagné
	$nextLevel/Retry/NextLevelButton.text = "Niveau suivant" # Le joueur peut passer au prochain niveau
	$nextLevel/Retry.show() # On affiche le menu de fin de niveau


# Fonction appelée lors de la défaite du joueur en solo
# Affiche un texte de défaite, le score, ainsi que les boutons Rejouer et Menu
# On en profite aussi pour stopper la musique de partie et lancer celle du menu
func _on_Player_Death():
	get_parent().get_node("LevelMusic").stop()
	get_parent().get_node("MenuMusic").play()
	var txt = lostTexts[rng.randi_range(0,lostTexts.size()-1)]
	$nextLevel/Retry/ScoreLabel.text = "SCORE :\n {score}".format({ "score" : str(score)}) # On affiche le score
	$nextLevel/Retry/MessageLabel.text = txt # On signale au joueur qu'il a perdu
	$nextLevel/Retry/NextLevelButton.text = "Rejouer" # Le joueur peut recommencer un niveau similaire
	$nextLevel/Retry.show() # On affiche le menu de fin de niveau


# Fonction appelée lorsque la partie en multijoueur est terminée
# Affiche un texte pour savoir qui a gagné en fonction de sa couleur
# Affiche aussi un bouton Rejouer et un bouton Menu
func _on_End_Multi(id_joueur):
	var txt = multiEndTexts[rng.randi_range(0,multiEndTexts.size()-1)]
	$nextLevel/Retry/ScoreLabel.hide() # On n'affiche pas le score
	if (id_joueur == -1) :
		txt = multiDrawEndTexts[rng.randi_range(0,multiDrawEndTexts.size()-1)]
		$nextLevel/Retry/MessageLabel.text = txt # On signale quel joueur a gagné
	else :
		$nextLevel/Retry/MessageLabel.text = txt.format({ "color" : str(colors[id_joueur])}) # On signale quel joueur a gagné
	$nextLevel/Retry/NextLevelButton.text = "Rejouer" # Le joueur peut relancer une partie en multijoueur
	$nextLevel/Retry.show() # On affiche le menu de fin de niveau


# Fonction appelée lors de l'appui sur le bouton de menu
# On joue alors le son d'appui sur un bouton, on stoppe les musiques de jeu s'il y en avait
# Et on joue celle du menu
func _on_MenuButton_pressed():
	get_parent().nb_player=1
	get_parent().get_node("Validate").play()
	get_parent().get_node("LevelMusic").stop()
	get_parent().get_node("MultiMusic").stop()
	get_parent().get_node("MenuMusic").play()
	get_parent().retour_accueil()

# Fonction appelée lors de l'appui sur le bouton Rejouer / Prochain Niveau
# On joue alors le son d'apui sur un bouton et on stoppe le musique du menu
# On finit par lancer une nouvelle partie
func _on_NextLevelButton_pressed():
	get_parent().get_node("Validate").play()
	get_parent().get_node("MenuMusic").stop()
	get_parent().new_maze()
	get_parent().kill_endOfGame()

# Fonction appelée lorsque la souris survole le bouton Menu
# On joue alors le son correspondant
func _on_MenuButton_mouse_entered():
	get_parent().get_node("Select").play()

# Fonction appelée lorsque la souris survole le bouton Rejouer / Prochain Niveau
# On joue alors le son correspondant
func _on_NextLevelButton_mouse_entered():
	get_parent().get_node("Select").play()

