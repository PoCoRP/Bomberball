extends "res://addons/gut/test.gd"

var mazeScene = preload("res://src/Maze/Maze.tscn") # Chargement de la scene du labyrinthe
onready var maze # Variable qui permet de stocker le labyrinthe une fois la variable chargée


# Méthode appelée au début de l'exécution du script qui permet d'instancier un labyrinthe avec certains paramètres
func before_all():
	maze = mazeScene.instance() # On instancie un labyrinthe
	maze.nb_player = 1 # Le nombre de joueur est paramètrée à 1
	maze.difficulty = 10 # La difficultée est paramètrée à 10
	maze.maze = maze # On stocke notre instance de maze dans la variable globale
	maze._ready() # Appel de la méthode _ready de maze pour tout charger

# Méthode appelée après tous les tests pour libérer la mémoire
func after_all():
	maze.queue_free()

# Méthode qui permet de tester s'il y a bien 1 joueur dans le labyrinthe
func test_nbPlayerSolo():
	assert_eq(maze.playersList.size,1,"vérification du nombre de joueur") # Comparaison de la taille de la liste de joueur avec 1

# Méthode qui permet de tester si le HUD est bien activé en solo
func test_hudShowSolo():
	assert_eq(maze.get_node('HUD').is_visible(),true,"vérification de l'activation du HUD en solo") # Comparaison de l'état du HUD avec true

# Méthode qui permet de tester si les cases autour du joueur sont bien libre pour ne pas le bloquer au début
func test_posPlayer():
	var check: bool = true # Variable booléenne qui va passer à false s'il y a un mur proche du spawn d'un joueur
	var pos = maze.playerPositions[0] # On récupère la position du spawn du joueur
	for wallPos in maze.getWallsPos(): # On parcours toutes les positions des murs
		if pos == wallPos: # On vérifie s'il n'y a pas de mur sur le spawn
			check = false
		if !(abs(pos.x - wallPos.x) > 1): # On vérifie s'il n'y a pas de mur à droite ou à gauche
			check = false
		if !(abs(pos.y-wallPos.y) > 1): # On vérifie s'il n'y a pas de mur au dessus ou en dessous
			check = false
	assert_eq(check,true,"vérification des espaces libres autour des spawn du joueur") # Comparaison de la variable check avec true pour savoir si le joueur est bloqué par un mur au spawn
