class_name Enemy extends KinematicBody2D

# Variables permettant de gérer les déplacements d'un ennemi
var speed: float = 100 # Vitesse de l'ennemi
var path: PoolVector2Array # Tableau de vector2 qui permet de stocker le chemin que doit suivre l'ennemi
var indice: int = 0 # Position actuelle dans le path
var direction: int = 1 # Variable permettant de savoir dans quel sens se déplace l'ennemi
var maze: TileMap # Variable permettant de stocker la TileMap du maze pour savoir comment se déplacer
var pre: KinematicCollision2D # Variable permettant de stocker l'objet qui vient d'entrer en collision avec l'ennemi

var isChasing = false; # Variable permettant de savoir si l'ennemi suit un joueur

var chasingPlayer; # Variable stockant le joueur qui est suivi

var type; # Variable permettant de gérer le type de l'ennemi

onready var rng = RandomNumberGenerator.new()


# Remplace les valeurs étant NaN d'un vecteur par des 0
func deNan(n):
	return Vector2(n.x if !is_nan(n.x) else 0, n.y if !is_nan(n.y) else 0);


# Renvoie un tableau de coordonnées constituant un chemin bouclant sur lui-même
# Commençant à la position actuelle de l'ennemi.
# La longueur dépend d'un paramètre aléatoire
# On commence par faire la moitié du chemin en prenant aléatoirement une nouvelle case adjacente à chaque fois
# Puis le retour se fait grâce à un algorithme astar, l'ennemi fera donc demi tour pour revenir à son
# Point de départ, en essayant le plus possible d'éviter les cases par lesquelles il est déja passé
# Pour éviter qu'il revienne simplement sur ses pas.
func getNewPassivePath():
	maze.setup()
	var newPath : PoolVector2Array = [];
	var directionTab = [Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)]

	var probaPath = 1.0;

	if type == 0:
		probaPath = 0.8;

	var nextPos
	var n = 0;

	var posEnCours = maze.world_to_map(position);
	newPath.append(posEnCours)
	directionTab.shuffle();

	while n < probaPath:
		randomize();
		var goodDirection = Vector2(0,0);
		for d in directionTab:
			nextPos = posEnCours+d;
			if (maze.get_cell(nextPos.x, nextPos.y) == 15) && !(nextPos in newPath) :
				goodDirection = d;
				break;

		if goodDirection == Vector2(0,0):
			for d in directionTab:
				nextPos = posEnCours+d;
				if (maze.get_cell(nextPos.x, nextPos.y) == 15):
					goodDirection = d;
					probaPath -= 0.07;
					break;
		n = rng.randf()
		directionTab.shuffle()
		newPath.append(nextPos)
		posEnCours = nextPos
		probaPath -= 0.02;

	var retour = maze._get_path(newPath[newPath.size()-1], newPath[0])

	path = newPath + retour;
	indice = 0;

# Renvoie un tableau de positions établissant un chemin entre la case courante de l'ennemi
# Et la position du joueur passée en paramètre
func getPathToPlayer(playerPos):
	var newPath;
	maze.setup()
	var pathSansMurs = maze._get_path(maze.world_to_map(position), playerPos)

	maze.removePoints(maze.get_parent().getWallsPos())
	var pathAvecMurs = maze._get_path(maze.world_to_map(position), playerPos)

	if pathAvecMurs.size() > 0:
		newPath = pathAvecMurs
	else:
		newPath = pathSansMurs;

	path = newPath
	indice = 0 if path.size() <= 1 else 1

# Assigne aléatoirement un type d'ennemi à l'ennemi en cours
# Parmi passif, actif et aggressif
# Et lui donne une texture et une animation en conséquence
func getType():
	type = rng.randi_range(0,2);
	var tabAnim = ["passive","active","agressive"]
	$AnimatedSprite.play(tabAnim[type])

# Fonction lancée à l'instanciation de l'ennemi
# Sert à seeder le générateur de nombres aléatoires
# Et à donner un nouveau chemin aléatoire à l'ennemi
# On en profite pour créer un timer qui donnera un nouveau chemin
# Toutes les 15 secondes à l'ennemi si il est actif
func _ready():
	rng.randomize()
	randomize();
	maze = get_parent().get_node("TileMap")
	if path.empty():
		path.append_array([maze.world_to_map(position)])
	getType();
	var timer = Timer.new()
	# Si l'ennemi est de type actif
	if type == 1:
		# On donne le délai du timer
		timer.set_wait_time(15)
		# On le fait se répeter
		timer.set_one_shot(false)
		# Et à chaque fin de timer on souhaite lancer getNewPassivePath
		timer.connect("timeout", self, "getNewPassivePath")
		# On l'ajoute à l'ennemi
		add_child(timer)
		# On le lance
		timer.start()

	# On donne un nouveau chemin aléatoire à l'ennemi
	getNewPassivePath()

# Fonction lancée à chaque frame permettant de déplacer l'ennemi en fonction du chemin généré
# Permet aussi de gérer les collisions lors des déplacements
func _process(delta):
	if path.size() == 0:
		path.append(maze.world_to_map(position))

	# Code permettant de gérer les déplacement dans le path avec les collisions pour savoir lorsqu'il faut faire demi tour
	var velocity: Vector2 = (maze.map_to_world(path[indice]) + Vector2(32, 32) - position).normalized()*speed # On calcule la vélocité en regardant la destination et la position actuelle
	var collision: KinematicCollision2D = move_and_collide(velocity*delta) # Move_and_collide permet de déplacer l'ennmi et renvoi quelque chose s'il y a une collision
	# Cas où il y a une collision lors du déplacement
	if collision:
		# On commence par regarder si l'objet collisionné est un joueur, si c'est le cas on supprime le joueur
		if collision.collider.has_method("setup_bomb"): # Le has_method permet de savoir si c'est bien un joueur
			collision.collider.queue_free()
			collision.collider.lose() # Pour afficher la page de défaites
		# Il faut maintenant vérifier qu'on ne collisionne pas 2 fois le même objet pour éviter de rester bloqué
		if pre != collision: # Si l'objet collisionné n'était pas déjà en collision juste avant
			if direction == 1:
				direction = -1 # On change la direction
				indice +=direction # Et on change l'indice de destination de 1 en fonction de la direction
				indice = indice % path.size() # Modulo pour rester dans les indices du tableau
			# Pareil mais pour l'autre direction
			else:
				direction = 1
				indice+= direction
				indice = indice % path.size()
			pre = collision # On stocke l'objet que l'on vient de collisionné dans la variable pre pour vérifier si c'est le même objet lors de la collision suivante
	# Il faut maintenant remettre à null la variable pre lorsqu'il n'y a pas de collision
	else:
		pre = null
	if isChasing:
		if maze.world_to_map(chasingPlayer.position) != path[path.size()-1]:
			getPathToPlayer(maze.world_to_map(chasingPlayer.position))

	# Code permettant de changer de destination pour passer à la suivante lorsque l'ennemi est arrivé à destination
	if path.size() > 0: # On vérifie qu'il a bien un chemin
		# On regarde si les coordonnée de l'ennemi sont les même que celle de la destination
		if (abs(round(position.x) - (maze.map_to_world(path[indice]) + Vector2(32, 32)).x) < 2) && (abs(round(position.y) - ((maze.map_to_world(path[indice]) + Vector2(32, 32)).y)) < 2) :
			indice+= direction # On change de destination
			indice = indice % path.size() # Modulo pour rester dans les indices du tableau

# Méthode qui est appellée par Bomb.gd si l'ennemi est touché par l'explosion d'une bombe
# Il est alors détruit
func bombed():
	queue_free() # On supprime l'ennemi
	get_parent().get_parent().change_score("Kill") # On ajoute du score


# Si quelque chose entre dans le rayon de vision de l'ennemi
# Sert à faire que les ennemis aggressifs chassent les joueurs si ils sont assez près
func _on_Area2D2_body_entered(body):
	if body.has_method("setup_bomb") && type == 2: # On vérifie que c'est bien un ennemi agressif et que l'objet dans la zone est un joueur
			isChasing = true;
			chasingPlayer = body; # On stocke le joueur suivit
			speed = 150; # On augmente la vitesse
			$AnimatedSprite.play("agressiveChasing") # On change l'animation pour utiliser celle lors de la poursuite
			var posPlayer = maze.world_to_map(body.position) # On récupère la position du joueur
			getPathToPlayer(posPlayer)

# Si un objet quitte le rayon de vision de l'ennemi
# Sert à rendre son comportement normal à un ennemi
func _on_Area2D2_body_exited(body):
	if body.has_method("setup_bomb") && type == 2: # On vérifie que c'est bien un ennemi agressif et que l'objet qui sort de la zone est un joueur
		chasingPlayer = null
		isChasing = false;
		speed = 100 # On réduit la vitesse
		$AnimatedSprite.play("agressive") # On change l'animation pour utiliser celle de base
		getNewPassivePath() # On génère un nouveau chemin

