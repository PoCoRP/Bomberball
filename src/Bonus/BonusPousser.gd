extends Area2D

############### FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand un corps entre dans un bonus permettant de pousser les bombes
func _on_Bonus_body_entered(body):
	if body.has_method("pousseBombe"): # On vérifie que le corps appelé est un joueur
		get_parent().get_parent().get_node("BonusPickUp").play() # On joue une mélodie
		body.pousseBombe() # Le joueur utilise la fonction permettant de pousser les bombes
		queue_free() # Le bonus disparaît
