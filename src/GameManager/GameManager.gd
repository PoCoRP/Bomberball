extends Node



#################### VARIABLES #############################

# Déclaration des différentes scènes en les chargeant depuis un path
# Chargement de la scène d'accueil
var accueil_scene = load("res://src/Menu/MainMenu/MainMenu.tscn")
# Chargement de la scène de fin de partie/niveau
var endofgame_scene = load("res://src/EndOfGame/endOfGame.tscn")
# Chargement de la scène de maze
var maze_scene = load("res://src/Maze/Maze.tscn")

#-----------------------------------------------------------
# Déclaration des différentes instanciations liées aux scènes
# Animation du centre de l'explosion
var accueil_instance
# Instance de fin de partie/niveau
var endofgame_instance
# Instance de la maze
var maze_instance

#-----------------------------------------------------------
# Déclaration des variables utiles à la maze
# Difficulté de la maze pour le mode solo
var maze_difficulty = 0.1;
# Nombre de joueur pouvant intéragir
var nb_player = 1;

#------------------------------------------------------------
# Variable du score du joueur en mode solo
var player_score = 0



##############################################################
##################### READY ##################################
# Lance une instance du splash screen (écran d'accueil) en fils du GameManager.
# Affiche cette instance.
func _ready():
	accueil_instance = accueil_scene.instance() # Instanciation de la page d'accueil
	self.add_child(accueil_instance) # Ajoute cette instanciation en fils du gameManager
	accueil_instance.show() # Affiche la page d'accueil




#############################################################
##################### GETTERS ###############################
# Retourne la valeur de la variable maze_difficulty
func get_difficulty():
	return (maze_difficulty)
#-----------------------------------------------------------
# Retourne la valeur de la variable nb_player
func get_nbPlayer():
	return (nb_player)




#############################################################
##################### SETTERS ###############################
# Met à jour la valeur de la variable nb_player
func set_nb_player(nbPlayer) :
	nb_player = nbPlayer

#--------------------------------------------------------------------------
# Fonction permettant d'incrémenter le score en fonction des actions du joueur
func change_score(action):
	if (action == "Bonus"): # S'il a récupéré un bonus il gagne 30 points
		player_score += 30
	elif (action == "Break"): # S'il a cassé un mur cassable, il marque 10 points
		player_score += 10
	elif (action == "Kill"): # S'il a tué un ennemi, il marque 60 points
		player_score += 60
	elif (action == "Victory"): # S'il a tué un ennemi, il marque 60 points
		player_score += 100





#############################################################
##################### KILLERS ###############################
## Les killers permettent de libérer les instanciations

# Permet de libérer l'instance de l'écran d'acceuil
func kill_accueil():
	accueil_instance.queue_free()

#-------------------------------------------------------------
# Permet de libérer l'instance de l'écran d'acceuil
func kill_maze():
	maze_instance.queue_free()

#------------------------------------------------------------
# Permet de libérer l'instance de l'écran d'acceuil
func kill_endOfGame():
	endofgame_instance.queue_free()




#############################################################
##################### CONSTRUCTORS ###############################

# Permet d'instancier et d'afficher la maze
func new_maze():
	maze_instance = maze_scene.instance() # Instanciation
	self.add_child(maze_instance) # L'instance est indiquée comme enfant du game manager
	maze_instance.show() # Affichage

#----------------------------------------------------------------
# Permet d'instancier et d'afficher l'écran d'accueil (après une fin de partie)
func retour_accueil():
		kill_endOfGame() # Libération de la page de fin de partie
		accueil_instance = accueil_scene.instance() # Instanciation de la page de fin de partie (défaite)
		self.add_child(accueil_instance) # Ajout de cette instanciation en fils du gameManager
		accueil_instance.show() # Affichage la page de défaite

#----------------------------------------------------------------
# Permet d'instancier et d'afficher l'écran de défaite en solo
func defeat():
	if (nb_player == 1): # Si la partie était en mode SOLO
		kill_maze() # Libération de la maze
		endofgame_instance = endofgame_scene.instance() # Instanciation de la page de fin de partie (défaite)
		self.add_child(endofgame_instance) # Ajoute cette instanciation en fils du gameManager
		endofgame_instance.set_score(player_score)
		endofgame_instance._on_Player_Death() # Affiche la page de défaite
	else : # Si la partie était en mode MULTIJOUEUR
		pass # Rien ne change, la partie n'est pas terminée


#----------------------------------------------------------------
# Permet d'instancier et d'afficher l'écran de victoire en solo
func victory():
	maze_difficulty+=1.1
	if (nb_player == 1): # Si la partie était en mode SOLO
		kill_maze() # Libération de la maze
		endofgame_instance = endofgame_scene.instance() # Instanciation de la page de fin de partie (victoire)
		self.add_child(endofgame_instance) # Ajoute cette instanciation en fils du gameManager
		endofgame_instance.set_score(floor(player_score*(1+maze_difficulty)*121))
		endofgame_instance._on_Player_Victory() # Affiche la page de victoire
	else : # Si la partie était en mode SOLO
		pass # Rien ne change, la partie n'est pas terminée

#----------------------------------------------------------------
# Permet d'instancier et d'afficher l'écran de fin de partie multi
func multi(id_joueur):
	kill_maze() # Libération de la maze
	endofgame_instance = endofgame_scene.instance() # Instanciation de la page de fin de partie (multijoueur)
	self.add_child(endofgame_instance) # Ajoute cette instanciation en fils du gameManager
	endofgame_instance._on_End_Multi(id_joueur) # Affiche la page de fin de partie multijoueur


