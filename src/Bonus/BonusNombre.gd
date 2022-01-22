extends Area2D

############### FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand un corps entre dans un bonus augmentant le nombre de bombes
func _on_Bonus_body_entered(body):
	if body.has_method("augmenteBombCapacity"): # On vérifie que le corps appelé est un joueur
		get_parent().get_parent().get_node("BonusPickUp").play() # On joue une mélodie
		body.augmenteBombCapacity() # Le joueur utilise la fonction augmentant son nombre de bombes
		queue_free() # Le bonus disparaît
