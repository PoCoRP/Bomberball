extends Area2D

############### FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand un corps entre dans un bonus permettant d'augmenter la portée des bombes
func _on_Bonus_body_entered(body):
	if body.has_method("augmenteRange"): # On vérifie que le corps appelé est un joueur
		get_parent().get_parent().get_node("BonusPickUp").play() # On joue une mélodie
		body.augmenteRange() # Le joueur utilise la fonction permettant d'augmenter la portée des bombes
		queue_free() # Le bonus disparaît
