extends TileMap

# - - Variables - -

var astar : AStar2D; # Objet Godot permettant de créer et de gérer des chemins grâce un algorithme A*
var used_cells; # Cases étants utilisables (= cases avec du sol et non des murs incassables)
var path : PoolVector2Array # Chemin retourné par l'algorithme A*


# - - Fonctions - -

# Permet de rendre des cases non empruntables depuis un tableau de cases
# Utile pour tenter d'avoir un chemin qui ne repasse pas par des cases déja empruntées
func removePoints(pts):
	for p in pts:
		astar.remove_point(id(p))

# Fonction de préparation,
# Sert à initialiser les variables déclarées plus tôt
# À ajouter les points empruntables au gestionnaire A* et à les relier entre eux
func setup():
	astar = AStar2D.new()
	used_cells = get_used_cells_by_id(15);
	_add_points()
	_connect_points()

# Fonction lancée à l'instanciation, sert à lancer la préparation
func _ready():
	setup()
	astar.reserve_space(13*11)

# Ajoute les points listés dans used_cells u gestionnaire A*
func _add_points():
	for cell in used_cells:
		astar.add_point(id(cell), cell, 1.0);

# Relie les points du gestionnaire A* entre eux
# Pour lui dire qu'il est possible de passer d'une case à une autre si elles sont
# Directement adjacentes, utilise un système d'identifiant unique à chaque case en fonction
# De ses cooronnées
func _connect_points():
	for i in range(1,14):
		for j in range(1,12):
			if get_cellv(Vector2(i,j)) in [15, 2, 5]:
				var idx=id(Vector2(i,j))
				for vNeighborCell in [Vector2(i,j-1),Vector2(i,j+1),Vector2(i-1,j),Vector2(i+1,j)]:
					var idxNeighbor=id(vNeighborCell)
					if astar.has_point(idxNeighbor):
						astar.connect_points(idx, idxNeighbor, false)

# Renvoie le chemin le plus court empruntant les cases entrées dans le gestionnaire A*
# Partant de start pour aller à end
func _get_path(start, end):
	path = astar.get_point_path(id(start), id(end));
	return path

# Renvoie l'identifiant d'un point en fonction de ses coordonnées
func id(point):
	return point.y+point.x*self.get_used_rect().size.y;

