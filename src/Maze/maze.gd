extends Node

# - - Preload des scènes qui seront utiles - -
var Enemy = preload("res://src/Enemy/Enemy.tscn")
var bonusVitesse = preload("res://src/Bonus/BonusVitesse.tscn")
var bonusRange = preload("res://src/Bonus/BonusRange.tscn")
var bonusPousser = preload("res://src/Bonus/BonusPousser.tscn")
var bonusNombre = preload("res://src/Bonus/BonusNombre.tscn")
var bonusLumiere = preload("res://src/Bonus/BonusLumiere.tscn")
var bonusGodMode = preload("res://src/Bonus/BonusGodMode.tscn")

var caillou = preload("res://src/Wall/Wall.tscn")
var bonusWall = preload("res://src/Wall/BonusWall.tscn")

var player_model = preload("res://src/Player/Player.tscn")

var wall1 = preload("res://imgs/Murs cassbles/murs_cassable1.png")
var wall2 = preload("res://imgs/Murs cassbles/murs_cassable2.png")
var wall3 = preload("res://imgs/Murs cassbles/murs_cassable3.png")
var wall4 = preload("res://imgs/Murs cassbles/murs_cassable4.png")


# - - Constantes - -

# Variables servant à stocker l'identifiant des tiles que l'on souhaite placer
var obsidian = [16, 17 ,18];
var sol = 15;
var exit = 20;

# Variables permettant de paramétrer la génération
var length = 15; # Longueur extérieure du labyrinthe en cases
var width = 13; # Largeur extérieure du labyrinthe
var genSpeed = 1; # Multiplicateur de lenteur de génération (> 0, + petit = + rapide)
var probaWallMin = 0.2; # Probabilité minimum de faire apparaitre un mur (difficulté faible)
var probaWallMax = 0.95 # Probabilité maximum de faire apparaitre un mur (difficulté forte)
var baseProbaEnemyPath = 0.6; # Probabilité de base de créer un chemin pour un ennemi
var minusProbaEachTurn = 0.15; # Probabilité retirée à la précédente chaque tour
var distanceMinSpawnExit = 8; # Distance minimale requise entre le point de spawn et la sortie
var distanceMinSpawnEnemy = 5; # Distance minimale requise entre le spawn et un enemi
var nbMaxEnemy = 7; # Nombre maximal d'ennemis
var probaBonus = 0.2; # Probabilité de base d'avoir un mur cassable avec bonus au lieu d'un mur cassable lambda

var spawnEnnemies = true; # [Debug] Ennemis activés
var spawnWalls = true; # [Debug] Murs cassables activés
var spawnExit = true # [Debug] Apparition de la sortie


# - - Variables globales - -
var probaWall; # Probabilité d'avoir un mur cassable sur une case
var spawnPos; # Position du spawn
var exitPos; # Position de la sortie
var playersSpawnPositions: PoolVector2Array # Tableau des positions des spawns des joueurs
var playersList:Array # Liste des joueurs
var enemyPositions: Array # Tableau des positions de spawn des ennemis
var nbEnemy; # Nombre d'ennemis
var walls : Array; # Tableau des murs cassables dans le labyrinthe
var textWalls = [wall1, wall2, wall3, wall4] # Tableau des textures des différents murs cassables

var player; # Joueur

var loaded:bool = false # Si le labyrinthe est chargé ou non

# - - Variables de références à d'autres objets/scènes - -

# Référence à la TileMap du labyrinthe
onready var maze : TileMap = get_node("/root/GameManager/Da World/TileMap");
# Générateur de nombre aléatoire
onready var rng = RandomNumberGenerator.new()

# Récupération des données de jeu (difficulté, nombre de joueurs, etc)
onready var GameManager = get_node("/root/GameManager")
onready var difficulty = GameManager.get_difficulty()
onready var nb_player = GameManager.get_nbPlayer()


###### - - FONCTIONS / PROCÉDURES - - ######


# Retourne un tableau contenant les positions des murs cassables du labyrinthe
func getWallsPos():
	var positions = []
	for w in walls:# Pour chaque mur
		if is_instance_valid(w): # Si il n'a pas été supprimé entre temps
			positions.append(maze.world_to_map(w.position)) # On ajoute sa position au tableau
	return positions

# Renvoie la distance de manhattan entre deux points
func manhattan(a : Vector2, b : Vector2):
	return (abs(a.x - b.x) + abs(a.y - b.y))

# Renvoie la probabilité d'avoir un mur cassable à une position en fonction de la difficulté
# Et des paramètres de génération comme la probabilité minimale d'avoir un mur cassable
func getNewProba():
	return (1-probaWallMin)/(-(difficulty/4+1))+1;

# Renvoie si un point est dans le labyrinthe ou non
func isInBounds(pos : Vector2):
	return pos.x <= length-2 && pos.y <= width-2 && pos.x >= 1 && pos.y >= 1

# Renvoie le nombre d'ennemis qu'il doit y avoir dans le labyrinthe en fonction de la difficulté
# Et des paramètres de génération comme nbMaxEnemy
# Il y a aussi aléatoirement 1 ennemi en plus ou en moins
func getNbEnemy():
	var baseNb = (1/(-((difficulty*0.08)+(1/(float(nbMaxEnemy)-1)))))+nbMaxEnemy;
	var randMmodif = rng.randf_range(-1, 1)
	return round(baseNb+randMmodif)

# Permet de générer un labyrinthe avec :
# - Des murs incassables selon un pattern donné
# - Des murs cassables aléatoirement selon la difficulté
# - Des murs cassables contenants un bonus aléatoirement
# - Un point de spawn dans un des coins du labyrinthe
# - Une sortie
# - Des ennemis selon la difficulté, ayant une position et un type aléatoire
# - Une gestion du multijoueur (pas de HUD, + de bonus, pas d'ennemis ni de sortie,...)

# Et suivant certaines règles :
# - Il y a 3 cases vides dans le coin du spawn (pour pouvoir poser une bombe)
# - La sortie est à + de distanceMinSpawnExit cases (manhattan) du spawn
# - Il n'y a pas d'ennemi à - de distanceMinSpawnEnemy case du spawn
func initMaze(nbPlayer : int):
	# Seeding du random
	randomize()
	if (nbPlayer > 1) :
		get_node('HUD').hide() # On cache le HUD en multijoueur
	# On crée un tableau contenant les 4 points de spawn possibles
	var spawnPossible: Array = []
	spawnPossible.append_array([Vector2(1,1),Vector2(length-2,1),Vector2(1,width-2),Vector2(length-2,width-2)])
	randomize()
	spawnPossible.shuffle() # On le mélange

	# Et on assigne à chaque joueur un point de spawn du tableau, aléatoirement comme le tableau est mélangé
	for i in range(nbPlayer):
		playersSpawnPositions.append(spawnPossible[i])

	# On stocke la position du point de spawn du premier joueur, sert pour le mode solo
	spawnPos = playersSpawnPositions[0]

	# - - Mise en place de la structure du labyrinthe => sol et murs incassables - -

	# Pour chaque case du labyrinthe
	for i in range(length):
		for j in range(width):
			# Une case sur deux et une ligne sur deux
			if i*j == 0 || i==length-1 || j == width-1 || (i%2==0 && j%2 == 0):
				# On pose un bloc incassable
				maze.set_cell(i, j, obsidian[rng.randi_range(0,2)]);
			else: # Sinon on pose une tile de sol
				maze.set_cell(i, j, sol);

	# - - Murs, sols et murs cassables - -

	# On récupère la probabilité d'avoir un mur à chaque case en fonction de la difficulté
	probaWall = getNewProba();
	# On récupère un tableau de toutes les positions possibles de case du labyrinthe
	var poses = combinaisons([range(length), range(width)])
	# On mélange ce tableau pour prendre les cases du labyrinthe de manière aléatoire
	# Sert pour avoir une animation qui placce les blocs aléatoirement et pas par ligne / colonne
	poses.shuffle();

	# Pour chacune de ces positions
	for p in poses:
		var i = p[0];
		var j = p[1];

		# Ptite animation qui fait plaisir
		# Si on est en multi
		if nb_player > 1:
			# On fait une légère pause avec un timer
			var t = Timer.new()
			t.set_wait_time(0.01*genSpeed)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free() # ... Qu'on finit par supprimer

		# Si On est sur une case de bloc incassable on passe à la case suivante
		if i*j == 0 || i==length-1 || j == width-1 || (i%2==0 && j%2 == 0):
			continue;
		else: # Sinon
			# Paramètres aléatoires
			var r = rng.randf();
			var rBonus = rng.randf()


			# On fait un test aléatoire pour savoir si on doit poser un mur cassable
			if r < probaWall:
				# Idem pour savoir si c'est un mur avec bonus
				if rBonus < probaBonus: # Si c'est un mur bonus qu'on pose
					var check: bool = true
					# Si la case n'est pas sur une case qui est trop près du spawn d'un joueur
					for pos in playersSpawnPositions:
						check = (abs(pos.x-i) > 1 || abs(pos.y-j) > 1) && check
					if check: # Si elle ne dérange aucun spawn
						# On crée un mur cassable avec bonus
						var c = bonusWall.instance();
						c.solo = nb_player == 1
						# On le place
						c.set_position(Vector2(maze.map_to_world(Vector2(i,j)))+Vector2(32,32))
						add_child(c);
						# On l'ajoute au tableau de murs cassables
						walls.append(c);
				else: # Si on doit poser un mur cassable classique

					# On fait le même test pour savoir si ça gène un spawn
					var check: bool = true
					for pos in playersSpawnPositions:
						check = (abs(pos.x-i) > 1 || abs(pos.y-j) > 1) && check
					if check: # Si la case est valide
						# On crée un objet mur, on le place, on l'ajoute à la scène et au tableau de murs
						var c = caillou.instance();
						c.set_position(Vector2(maze.map_to_world(Vector2(i,j)))+Vector2(32,32))
						c.get_node("Sprite").set_texture(textWalls[rng.randi_range(0,3)])
						add_child(c);
						walls.append(c);


	# - - - Sortie - - -

	if spawnExit: # Si on souhaite faire apparaitre une sortie
		# On donne à la sortie un position aléatoire
		var randExitPos = Vector2(rng.randi_range(1, length-2), rng.randi_range(1, width-2))

		# Tant que cette position ne concient pas aux règles mises en place
		# Càd si il n'y a pas de mur incassable à cette position et que le spawn n'est pas trop près
		while maze.get_cell(randExitPos.x, randExitPos.y) in obsidian || manhattan(spawnPos, randExitPos) < distanceMinSpawnExit:
			# On donne une nouvelle position à la sortie
			randExitPos = Vector2(rng.randi_range(1, length-2), rng.randi_range(1, width-2))
		# On sort donc avec une position qui convient

		# On pérènnise cette position en la stockant dans une variable globale
		exitPos = randExitPos;

		# Si un mur est à la même position que la sortie, on le supprime
		for w in walls:
				if w.get_position()-Vector2(32,32) == maze.map_to_world(randExitPos):
					w.queue_free()
					walls.erase(w);

		# On affiche une tile de sortie à sa position
		maze.set_cell(randExitPos.x, randExitPos.y, exit)


	# - - - Ennemis - - -
	if spawnEnnemies:
		nbEnemy = getNbEnemy(); # On récupère le nombre d'ennemis à ajouter
		for _e in range(nbEnemy):
			if nb_player > 1: # On vérifie que le jeu est bien en multi pour faire l'animation d'apparition des ennemis
				# Le timer permet de faire l'animation des ennemis qui apparaissent les uns après les autres
				var t = Timer.new()
				t.set_wait_time(0.1*genSpeed)
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
				t.queue_free()

			var randEnemyPos = Vector2(rng.randi_range(1, length-2), rng.randi_range(1, width-2)) # On génère un spawn aléatoire pour l'ennemi

			# Si la case n'est pas possible on en génère une nouvelle jusqu'à ce que cette case soit valide
			while maze.get_cell(randEnemyPos.x, randEnemyPos.y) in (obsidian + [exit]) ||\
				manhattan(spawnPos, randEnemyPos) < distanceMinSpawnEnemy:

					randEnemyPos = Vector2(rng.randi_range(1, length-2), rng.randi_range(1, width-2))

			enemyPositions.append(randEnemyPos); # On ajoute la nouvelle position au tableau des positions de spawn des ennemis
			# On parcours tous les murs afin de regarder s'il faut l'enlever pour laisser la place à un ennemi
			for w in walls:
				if w.get_position()-Vector2(32,32) == maze.map_to_world(randEnemyPos): # On regarde s'il y a un mur à la place du spawn d'un ennemi
					w.queue_free()
					walls.erase(w);
			maze.set_cell(randEnemyPos.x, randEnemyPos.y, sol); # La case de spawn de l'ennemi est un sol



	enemyPositions.shuffle() # Mélange du spawn des ennemis
	# On crée un chemin autour du spawn des ennemis
	for e in enemyPositions:
		if nb_player > 1:
			var t = Timer.new()
			t.set_wait_time(0.1*genSpeed)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
		alterPath(e, baseProbaEnemyPath);

	initEnemy() # Appel qui permet de générer les ennemis
	initPlayers() # Appel qui permet de générer les joueurs


# Fonction servant à instancier, initialiser et placer le(s) joueur(s) qui vont jouer
# Prend le nombre de joueurs en paramètres
func initPlayers():
	var nbPlayer = playersSpawnPositions.size()
	var idPlayer:int = 0
	for i in playersSpawnPositions:
		player = player_model.instance() # On instancie un nouveau joueur
		player.setId(idPlayer) # Le nouveau joueur a un id unique
		idPlayer+=1
		if(nbPlayer>1): # Si le jeu est multijoueur on enlève les lumières et le joueur a une seule vie
			player.disabledLight()
			player.heart = 1
		add_child(player)
		playersList.append(player) # On ajoute le joueur au tableau de joueur
		player.set_scale(Vector2(0.45, 0.45))
		player.position = maze.map_to_world(i)+Vector2(32, 32)
		player.show()
		loaded=true && nbPlayer !=1

	if playersList.size() == 1:
		get_node("HUD").getPlayer(playersList[0])


# Instancie, initialise et place les ennemis à partir de la liste des ennemis
func initEnemy():
	for i in enemyPositions:
		var e = Enemy.instance()
		e.position = maze.map_to_world(i) + Vector2(32, 32)
		self.add_child(e)

# Fonction récursive permettant de créer un chemin aléatoirement dans le labyrinthe case par case
# Pour les ennemis, à chaque nouvel appel la probabilité de rallonger le chemin diminue
func alterPath(pos : Vector2, proba : float):
	if nb_player > 1:
		var t = Timer.new()
		t.set_wait_time(0.1*genSpeed)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()

	for k in range(-1, 2):
		for l in range(-1, 2):
			if k!=l && k*l == 0:
				var newPos = pos + Vector2(k, l);
				if rng.randf() < proba &&\
				isInBounds(newPos) &&\
				maze.get_cell(newPos.x, newPos.y) in [sol]:
					for w in walls:
						if w.get_position()-Vector2(32,32) == maze.map_to_world(newPos) :
							w.queue_free()
							walls.erase(w)
							alterPath(newPos, proba-minusProbaEachTurn);



# Fonction lancée à l'initialisation de la scène de labyrinthe
# Sert à jouer la musique du mode de jeu choisi,
# Désactive les ennemis et la sortie si en multi
# Et initialise le labyrinthe
func _ready():
	if nb_player == 1:
		get_parent().get_node("LevelMusic").play()
	else:
		get_node("HUD").queue_free()
		get_parent().get_node("MultiMusic").play()
		genSpeed = 0.001
	rng.randomize();
	if nb_player>1: # On désactive le spawn des ennemis et la sortie en multijoueur
		spawnEnnemies = false
		spawnExit = false
	initMaze(nb_player)


# Fonction lancée à chaque frame du labyrinthe
# Sert à détecter quand un joueur est mort
func _process(_delta):
	if loaded:
		for p in playersList:
			if !is_instance_valid(p):
				playersList.remove(playersList.find(p))

		if playersList.size() == 1:
			if !is_instance_valid(playersList[0]) :
				get_parent().multi(-1)
			else :
				get_parent().multi(playersList[0].id)


# Renvoie toutes les combinaisons possibles entre plusieurs listes d'un tableau de listes
# Fonction récupérée ici : https://godotengine.org/qa/15813/function-that-returns-all-possible-combinations-sequence
func combinaisons(a):

	var r = []
	var a0 = a[0]

	if a.size() == 1:
		r.append(a0)
		return r
	var a1
	var t
	if a.size() > 2:
		a.pop_front()
		a1 = combinaisons(a)
		for i in a0:
			for j in a1:
				t = []
				t.append(i)
				for k in j: t.append(k)
				r.append(t)
	else :
		for i in a0:
			for j in a[1]:
				t = []
				t.append(i)
				t.append(j)
				r.append(t)
	return r
