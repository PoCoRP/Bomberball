extends Area2D


################ FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand un corps entre dans un bonus
func _on_Bonus_body_entered(_body):
	get_parent().get_node("BonusPickUp").play()# On joue une mélodie lorsqu'on entre dans un bonus
	queue_free()# Le bonus est pris donc il disparaît


