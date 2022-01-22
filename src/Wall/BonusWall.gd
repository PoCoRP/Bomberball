extends KinematicBody2D

# Chargement des scènes des différents bonus
var bonusVitesse = preload("res://src/Bonus/BonusVitesse.tscn") # Chargement de la scène du bonus vitesse
var bonusRange = preload("res://src/Bonus/BonusRange.tscn") # Chargement de la scène du bonus de portée
var bonusPousser = preload("res://src/Bonus/BonusPousser.tscn") # Chargement de la scène du bonus pousser
var bonusNombre = preload("res://src/Bonus/BonusNombre.tscn") # Chargement de la scène du bonus de nombre de bombes
var bonusLumiere = preload("res://src/Bonus/BonusLumiere.tscn") # Chargement de la scène du bonus lumière
var bonusGodMode = preload("res://src/Bonus/BonusGodMode.tscn") # Chargement de la scène du bonus God Mode

var solo:bool # Est ce que le mode de jeu est en solo

# - - Fonctions - -

# Fonction lancée à l'initialisation du mur cassable avec bonus
# Servant à donner une texture de départ aléatoire pour que les cycles
# De tous les murs cassables ne soient pas synchronisés
# On en profite pour rendre impossible l'obtention du bonus lumière en multijoueur
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if solo:
		$AnimatedSprite.play("solo")
		$AnimatedSprite.frame = rng.randi_range(0,5)
	else:
		$AnimatedSprite.play("multi")
		$AnimatedSprite.frame = rng.randi_range(0,4)

# Fonction appelée lorsque le mur est détruit par une bombe
# On fait donc aparaître un objet bonus en fonction de la texture qu'avait le mur
# Au moment d'être détruit
func bombed():
	var bonus
	match $AnimatedSprite.frame:
		5:
			bonus = bonusLumiere.instance()
		0:
			bonus = bonusNombre.instance()
		1:
			bonus = bonusVitesse.instance()
		2:
			bonus = bonusRange.instance()
		3:
			bonus = bonusPousser.instance()
		4:
			bonus = bonusGodMode.instance()

	bonus.position = position
	get_parent().add_child(bonus)
	queue_free();
