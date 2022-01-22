extends KinematicBody2D


################# VARIABLES #########################

var speed = 250 # Vitesse initiale du joueur

var Bombe = preload('res://src/Bomb/Bomb.tscn') # Scène de la bombe, pour pouvoir la poser

var bombRange = 2; # Portée initiale de la bombe

# Chargement des noms des animations pour les mouvements de joueurs
var animDown = ["downB", "downJ", "downR", "downV"] # Animations marcher vers le bas
var animIdleFront = ["idle_frontB", "idle_frontJ", "idle_frontR", "idle_frontV"] # Animation immobile vers le bas

var animUp = ["upB", "upJ", "upR", "upV"] # Animation marcher vers le haut
var animIdleBack = ["idle_backB", "idle_backJ", "idle_backR", "idle_backV"] # Animation immobile vers le haut

var animLeft = ["leftB", "leftJ", "leftR", "leftV"] # Animation marcher vers la gauche
var animIdleLeft = ["idle_leftB", "idle_leftJ", "idle_leftR", "idle_leftV"] # Animation immobile vers la gauche

var animRight = ["rightB", "rightJ", "rightR", "rightV"] # Animation marcher vers la droite
var animIdleRight = ["idle_rightB", "idle_rightJ", "idle_rightR", "idle_rightV"] # Animation immobile vers la droite


var isSingleplayer = true; # La partie est-elle en solo
onready var Maze = get_parent() # Référence au labyrinthe
var exitPos # Position de la sortie
var maze; # TileMap du labyrinthe
var screen_size # Pour stocker la taille de l'écran
var lastDirection = 0; # Dernière direction prise par le joueur
var bombList: Array # Liste des bombes posées par le joueur. Sert à limiter le nombre de bombes pouvant être posées simultanément
var bombCapacity: int =2 # Nombre de bombe initial que le joeur peut poser
var invincible = false # Situation du bonus GodMode
var light:bool = true # Si la lumière est allumée (= le bonus lumière est actif)
var heart = 3 # Nombre de vies en Solo
var lumi = false # Possesion du bonus Lumière
var nb = false # Possesion du bonus Nombre de Bombe
var pousse = false # Possesion du bonus Pousser
var rang = false # Possesion du bonus Portée
var vite = false # Possesion du bonus Vitesse
var id:int # ID du joueur (0, 1, 2, ou 3)

# Tableau des touches pour chaque joueur en fonction de son ID
var keyMapping = [["left_1","up_1","right_1","down_1","bomb_1"],["left_2","up_2","right_2","down_2","bomb_2"],["left_3","up_3","right_3","down_3","bomb_3"],["left_4","up_4","right_4","down_4","bomb_4"]]

################ FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée pour connaître le nombre de vies restantes
func getHeart():
	return heart

#-------------------------------------------------------------------------
# Fonction appelée pour savoir si on a le bonus GodMode
func getInvincible():
	return invincible

#-------------------------------------------------------------------------
# Fonction appelée pour savoir si on a le bonus Lumière
func getLumiere():
	return lumi

#-------------------------------------------------------------------------
# Fonction appelée pour savoir si on a le bonus Nombre de Bombes
func getNb():
	return nb

#-------------------------------------------------------------------------
# Fonction appelée pour savoir si on a le bonus Pousser
func getPousse():
	return pousse

#-------------------------------------------------------------------------
# Fonction appelée pour savoir si on a le bonus Portée
func getRange():
	return rang

#-------------------------------------------------------------------------
# Fonction appelée pour savoir si on a le bonus Vitesse
func getVite():
	return vite

#-------------------------------------------------------------------------
# Fonction appelée lorsqu'on a le bonus GodMode
# On lance un timer de 5 secondes pendant lequel le joueur sera invincible
# Et on augmente le score
func godmode():
	get_parent().get_parent().change_score("Bonus") # Le score change
	invincible = true # On a le bonus
	var t = Timer.new()
	t.set_wait_time(5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start() # On crée un timer de 5s
	yield(t, "timeout")
	invincible = false # Après la fin du timer on perd le bonus

#-------------------------------------------------------------------------
# Fonction appelée lorsqu'on a le bonus Lumière
# On enlève la restriction de vision, on lance un timer de 2 secondes
# Et on remet la restriction à la fin de ce dernier
# Et on augmente le score
func lumiere():
	get_parent().get_parent().change_score("Bonus") # Le score change
	lumi = true # On a le bonus
	$Sprite.visible = !$Sprite.visible
	get_node(get_child(3).name).set_enabled(!get_node(get_child(3).name).is_enabled()) # Le labyrinthe devient visible
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start() # On crée un timer de 2s
	yield(t, "timeout")
	$Sprite.visible = !$Sprite.visible
	get_node(get_child(3).name).set_enabled(!get_node(get_child(3).name).is_enabled())
	lumi = false # Après la fin du timer on perd le bonus

#-------------------------------------------------------------------------
# Fonction appelée lorsqu'on a le bonus Nombre de Bombes
# Qui sert simplement à incrémenter le nombre de bombes
# Et on augmente le score
func augmenteBombCapacity():
	get_parent().get_parent().change_score("Bonus") # Le score change
	bombCapacity +=1 # On augmente de 1 le nombre de bombe que l'on peut poser en même temps
	nb = true # On a le bonus

#-------------------------------------------------------------------------
# Fonction appelée lorsqu'on a le bonus Pousser
# Et on augmente le score
func pousseBombe():
	get_parent().get_parent().change_score("Bonus") # Le score change
	pousse = true # On a le bonus

#-------------------------------------------------------------------------
# Fonction appelée lorsqu'on a le bonus Portée
# On augmente la portée des bombes du joueur
# Et on augmente le score
func augmenteRange():
	get_parent().get_parent().change_score("Bonus") # Le score change
	bombRange +=1 # On augmente de 1 la portée de la bombe
	rang = true # On a le bonus

#-------------------------------------------------------------------------
# Fonction appelée lorsqu'on a le bonus Vitesse
# On augmente la vitesse du joueur
# Et on augmente le score
func augmenteSpeed():
	get_parent().get_parent().change_score("Bonus") # Le score change
	speed+=100 # On augmente de 100 la vitesse du joueur
	vite = true # On a le bonus

# Attribue un ID au joueur
func setId(i:int):
	id=i

# Désactive la restriction de vision
# Sert en multijoueur
func disabledLight():
	light= false
	$Sprite.visible = false

# Permet de poser une bombe
# On instancie une bombe, on la place à la position du joueur
# Et si le joueur a le bonus Pousser on met la bombe en mode character
func setup_bomb(bomb_name, pos):
	var bomb = Bombe.instance()
	bomb.set_name(bomb_name)
	bomb.position = pos
	bomb.resizeShape(bombRange)
	maze.add_child(bomb)
	bombList.append(bomb)
	if pousse == true :
		bomb.set_mode(RigidBody2D.MODE_CHARACTER) # Si on a le bonus pousser la bombe passe en mode character pour bouger




#-------------------------------------------------------------------------
# Fonction appelée quand le node entre pour la première fois sur la scène
# On détermine si nous sommes en solo ou en multijoueur
# Et le cas échéant on rajoute la restriction de lumière ou non
func _ready():
	exitPos = Maze.exitPos;
	maze = get_parent().get_node("TileMap");
	screen_size = get_viewport_rect().size

	isSingleplayer = light

	if light:
		var imgFile = "res://ressources/Player/LightSprite.png"


		var lightAdd: Light2D = Light2D.new()
		lightAdd.name = "LightAdd"
		add_child(lightAdd)
		lightAdd.texture = load(imgFile)
		lightAdd.set_color("a86969")
		lightAdd.set_shadow_enabled(true)

#--------------------------------------------------------------------------
# Fonction appelée à chaque frame du jeu
# Sert à gérer les déplacements, l'arrivée à la sortie,
# Les animations et la capacité de bombes
func _process(delta):
	# Inputs
	var velocity = Vector2(0,0)
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false) # Permet au joueur de ne pas traverser les murs
# Code en commentaire qui permet d'ajouter ou d'enlever de la portée aux bombes
#	if Input.is_action_just_pressed("custom1"):
#		bombRange += 1;
#
#	if Input.is_action_just_pressed("custom2"):
#		if bombRange >= 1:
#			bombRange -= 1;
# Code en commentaire qui permet d'enlèver la visibilité réduite si on appuie sur la touche L
#	if Input.is_action_just_pressed("lumiere") && isSingleplayer:
#		$Sprite.visible = !$Sprite.visible
#		get_node(get_child(3).name).set_enabled(!get_node(get_child(3).name).is_enabled())

	if Input.is_action_just_pressed(keyMapping[id][4]) and bombCapacity>0:
		bombCapacity-=1
		setup_bomb("Bomb1", maze.map_to_world(maze.world_to_map(global_position))+Vector2((64)/2, (64)/2))
	if Input.is_action_pressed(keyMapping[id][1]):
		velocity.y-=1
	if Input.is_action_pressed(keyMapping[id][2]):
		velocity.x+=1
	if Input.is_action_pressed(keyMapping[id][3]):
		velocity.y+=1
	if Input.is_action_pressed(keyMapping[id][0]):
		velocity.x-=1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed 
		$AnimatedSprite.play() 
		if maze.world_to_map(position) == exitPos:
			queue_free()
			win()
	else:
		$AnimatedSprite.stop()
	# Déplacements
	position+= velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0 , screen_size.y) # Le joueur doit rester dans l'écran de jeu
	# Gestion des animations
	if velocity.x != 0:
		if velocity.x > 0:
			if isSingleplayer:
				$AnimatedSprite.animation = "right"
			else:
				$AnimatedSprite.animation = animRight[id]
			lastDirection = 2;
		else:
			if isSingleplayer:
				$AnimatedSprite.animation = "left"
			else:
				$AnimatedSprite.animation = animLeft[id]
			lastDirection = 4;
	elif velocity.y !=0:
		if velocity.y > 0:
			if isSingleplayer:
				$AnimatedSprite.animation = "down"
			else:
				$AnimatedSprite.animation = animDown[id]
			lastDirection = 3;
		else:
			if isSingleplayer:
				$AnimatedSprite.animation = "up"
			else:
				$AnimatedSprite.animation = animUp[id]
			lastDirection = 1;
	else:
		if lastDirection == 1:
			if isSingleplayer:
				$AnimatedSprite.animation = "idle_back"
			else:
				$AnimatedSprite.animation = animIdleBack[id]
		elif lastDirection == 2:
			if isSingleplayer:
				$AnimatedSprite.animation = "idle_right"
			else:
				$AnimatedSprite.animation = animIdleRight[id]
		elif lastDirection == 4:
			if isSingleplayer:
				$AnimatedSprite.animation = "idle_left"
			else:
				$AnimatedSprite.animation = animIdleLeft[id]
		else:
			if isSingleplayer:
				$AnimatedSprite.animation = "idle_front"
			else:
				$AnimatedSprite.animation = animIdleFront[id]
	for i in bombList:
		if !is_instance_valid(i):
			bombList.remove(bombList.find(i))
			bombCapacity+=1


#--------------------------------------------------------------------------
# Fonction appelée lorsqu'on se fait toucher par une bombe
# On vérifie alors si le joueur est invincible, si ce n'est pas le cas
# Alors soit il perd une vie soit il perd la partie le cas échant
func bombed():
	if !invincible and heart <= 1:
		heart -=1
		queue_free();
		lose() # Si on a plus de vie et qu'on a pas le bonus GodMode, on perd
	elif !invincible:
		heart -=1 # On perd une vie si on est touché sans bonus GodMode

# Fonction en cas de victoire
# On prévient GameManager qu'on a gagné
func win():
	var GameManager = get_node("/root/GameManager")
	GameManager.change_score("Victory")
	GameManager.victory()

# Fonction en cas de défaite
# On prévient GameManager, on joue le son de défaite et on arrête la musique de jeu
func lose():
	var GameManager = get_node("/root/GameManager")
	get_parent().get_parent().get_node("GameOver").play()
	get_parent().get_parent().get_node("LevelMusic").stop()
	GameManager.defeat()
