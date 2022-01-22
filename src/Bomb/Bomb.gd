extends RigidBody2D


################# VARIABLES #########################
# Colision pour savoir si le joueur est sorti de la bombe lorsqu'il la pose
onready var cShape = get_node("Collision")
# Référence au GameManager, pour le prévenir quand il perd
onready var gameManager = get_node("/root/GameManager");

# Animation du centre de l'explosion
var ExC = preload("res://src/Explos/Explo_centre.tscn");
# Animation des bras centre de l'explosion
var ExM = preload("res://src/Explos/Explo_milieu.tscn");
# Animation du centre de l'explosion
var ExMC = preload("res://src/Explos/Explo_milieu_centre.tscn");
# Animation de la fin des bras de l'explosion
var ExF = preload("res://src/Explos/Explo_fin.tscn");

onready var exploded = false; # Si la bombe a déja explosé

var bomb_range = 3; # Portée de la bombe

var in_bomb_range = []; # Tableau des objets présents dans la zone d'explosion


################ FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand le node entre pour la première fois sur la scène
func _ready():
	set_angular_damp(200000000) # Permet à la bombe une absence de rotation

# Fonction servant à faire apparaître des textures d'explosion au moment
# De l'explosion de la bombe, en fonction de la portée de la bombe.
# Il faut aussi gérer le fait que les textures ne sont pas les mêmes au centre
# De l'explosion que sur les cotés ou au bout de la portée de l'explosion
func explodeTextures():
	set_mode(self.MODE_STATIC) # Au moment où la bombe explose elle ne peut plus bpuger
	var e = ExC.instance();
	e.set_position(Vector2(0,0))
	e.get_node("Sprite").play("boom")
	add_child(e);

	if bomb_range >= 1:
		# Haut
		e = ExMC.instance();
		e.set_position(Vector2(-64,0))
		e.set_rotation_degrees(90)
		e.get_node("Sprite").play("boom")
		add_child(e);
		# Droite
		e = ExMC.instance();
		e.set_position(Vector2(0,64))
		e.set_rotation_degrees(180)
		e.get_node("Sprite").play("boom")
		add_child(e);
		# Bas
		e = ExMC.instance();
		e.set_position(Vector2(64,0))
		e.set_rotation_degrees(90)
		e.get_node("Sprite").play("boom")
		add_child(e);
		# Gauche
		e = ExMC.instance();
		e.set_position(Vector2(0,-64))
		e.set_rotation_degrees(0)
		e.get_node("Sprite").play("boom")
		add_child(e);

	if bomb_range > 2:
		for i in range(bomb_range-1):
			# Haut
			e = ExM.instance();
			e.set_position(Vector2(-64*(i+1),0))
			e.set_rotation_degrees(90)
			e.get_node("Sprite").play("boom")
			add_child(e);
			# Droite
			e = ExM.instance();
			e.set_position(Vector2(0,64*(i+1)))
			e.set_rotation_degrees(180)
			e.get_node("Sprite").play("boom")
			add_child(e);
			# Bas
			e = ExM.instance();
			e.set_position(Vector2(64*(i+1),0))
			e.set_rotation_degrees(90)
			e.get_node("Sprite").play("boom")
			add_child(e);
			# Gauche
			e = ExM.instance();
			e.set_position(Vector2(0,-64*(i+1)))
			e.set_rotation_degrees(0)
			e.get_node("Sprite").play("boom")
			add_child(e);

	# Haut
	e = ExF.instance();
	e.set_position(Vector2(-64*bomb_range,0))
	e.set_rotation_degrees(90)
	e.get_node("Sprite").play("boom")
	add_child(e);
	# Droite
	e = ExF.instance();
	e.set_position(Vector2(0,64*bomb_range))
	e.set_rotation_degrees(0)
	e.get_node("Sprite").play("boom")
	add_child(e);
	# Bas
	e = ExF.instance();
	e.set_position(Vector2(64*bomb_range,0))
	e.set_rotation_degrees(270)
	e.get_node("Sprite").play("boom")
	add_child(e);
	# Gauche
	e = ExF.instance();
	e.set_position(Vector2(0,-64*bomb_range))
	e.set_rotation_degrees(180)
	e.get_node("Sprite").play("boom")
	add_child(e);


# Change les tailles de CollisionShape2D associées à la détection d'objets
# étant dans la zone d'explosion de la bombe, en fonction de sa portée
# R : rayon d'explosion en cases
func resizeShape(r):
	bomb_range = r;
	var shapeH = get_node("AreaExplo/CollisionShape2DExploH");
	var shapeV = get_node("AreaExplo/CollisionShape2DExploV");
	shapeH.shape.set_extents(Vector2((r)*64, 20));
	shapeV.shape.set_extents(Vector2(20, (r)*64));

# Fonction appelée lorsque la bombe a été posée, sert à initialiser des
# Variables nécessaires par la suite
func posed():
	exploded = false;
	contact_monitor = true;

# Fonction d'explosion de la bombe, lancée au terme du timer qui lui est associé
# Joue le son d'explosion, crée les textures d'explosion et détruit ce qui est à portée d'explosion
# Pour cela, on regarde ce qu'il y dans le tableau des objets présents dans la zone
# D'explosion et on appelle la fonction "bombed" de chacun de ces objets si
# Ils ont une telle méthode (= si ils peuvent être détruits)
func MACRONEXPLOSION():
	gameManager.get_node("Explosion").play()
	if !exploded:
		exploded = true
		explodeTextures()
		for p in in_bomb_range:
			if p.has_method("bombed"):
				p.bombed()
		pass

# Permet de ne pas pouvoir collisionner avec la bombe si elle vient d'être posée.
# On attend alors que le joueur ne soit plus sur la bombe pour la rendre collisionnable à nouveau
func _on_Area2D_body_exited(_body):
	cShape.set_deferred("disabled", false)

# Lorsqu'un objet entre dans la zone d'explosion de la bombe, on l'ajoute à un tableau
func _on_AreaExplo_body_entered(body):
	if not body in in_bomb_range:
		in_bomb_range.append(body)

# Lorsqu'un objet sort de la zone d'explosion de la bombe on le retire du tableau
func _on_AreaExplo_body_exited(body):
	in_bomb_range.erase(body)
