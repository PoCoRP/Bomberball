extends KinematicBody2D

# - - Fonctions - -

# Fonction appelée lorsque le mur est dans la zone d'explosion d'une bombe lors de son explosion
func bombed():
	queue_free();
	get_parent().get_parent().change_score("Break")
