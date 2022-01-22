extends Area2D

################ FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand un corps entre dans un bonus d'invincibilité
func _on_Bonus_body_entered(body):
	if body.has_method("godmode"): # On vérifie que le corps appelé est un joueur
		get_parent().get_parent().get_node("BonusPickUp").play() # On joue une mélodie
		body.godmode() # Le joueur utilise la fonction le rendant invincible
		queue_free() # Le bonus disparaît
