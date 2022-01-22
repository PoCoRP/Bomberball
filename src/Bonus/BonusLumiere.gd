extends Area2D

################ FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand un corps entre dans un bonus de lumière
func _on_Bonus_body_entered(body):
	if body.has_method("lumiere"): # On vérifie que le corps appelé est un joueur
		get_parent().get_parent().get_node("BonusPickUp").play() # On joue une mélodie
		body.lumiere() # Le joueur utilise la fonction rendant le labyrinthe visible
		queue_free() # Le bonus disparaît
