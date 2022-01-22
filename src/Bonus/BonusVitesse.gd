extends Area2D

############### FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand un corps entre dans un bonus permettant d'augmenter la vitesse
func _on_Bonus_body_entered(body):
	if body.has_method("augmenteSpeed"): # On vérifie que le corps appelé est un joueur
		get_parent().get_parent().get_node("BonusPickUp").play() # On joue une mélodie
		body.augmenteSpeed() # Le joueur utilise la fonction permettant d'augmenter sa vitesse
		queue_free() # Le bonus disparaît
