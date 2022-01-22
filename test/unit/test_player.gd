extends "res://addons/gut/test.gd"

var playerScene = preload('res://src/Player/Player.gd') # Chargement de la scene d'un joueur
onready var player = null # Variable qui permet de stocker le joueur une fois la variable chargée


# Méthode appelée au début de l'exécution du script qui permet d'instancier un joueur avec certains paramètres
func before_all():
	player = playerScene.instance() # On instancie un joueur
	player._ready() # Appel de la méthode _ready de joueur pour tout charger

# Méthode appelée après tous les tests pour libérer la mémoire
func after_all():
	player.queue_free()

# Méthode qui permet de tester que la capacité de bombe diminue de 1 lorsque le joueur pose une bombe
func test_nbBombCapacity():
	player.setup_bomb("Bomb1", player.global_position+Vector2((64)/2, (64)/2)) # On pose une bombe pour faire descendre la capacitée de bombe de 1
	assert_eq(player.bombCapacity,1,"vérification du nombre de bombe après en avoir posé une") # Comparaison du nombre de bombe avec l'entier 1

# Méthode qui permet de tester si le bonusRange augmente bien la range de 1
func test_bonusRange():
	player.augmenteRange()
	assert_eq(player.bombRange,3,"vérification de la range après avoir récupéré un bonus pour la range") # Comparaison de la range avec l'entier 3

# Méthode qui permet de tester si le bonusSpeed augmente bien la speed de 100
func test_bonusSpeed():
	player.augmenteSpeed()
	assert_eq(player.speed,350,"vérification de la speed après avoir récupéré un bonus pour la speed") # Comparaison de la speed avec l'entier 350

# Méthode qui permet de tester si le bonusBombCapacity augmente bien la capacité de 1
func test_bonusBombCapacity():
	player.augmenteBombCapacity()
	assert_eq(player.bombCapacity,3,"vérification de la capacité après avoir récupéré un bonus pour la capacité") # Comparaison de la capacité avec l'entier 3

# Méthode qui permet de tester si la méthode bombed diminue bien la vie de 1
func test_bombed():
	player.bombed()
	assert_eq(player.heart,2,"vérification de la vie après avoir été touché par une bombe") # Comparaison de la vie avec l'entier 2
