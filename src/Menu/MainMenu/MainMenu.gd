extends Control

#################### READY #####################################################
# Lorsque le menu d'accueil apparaît les boutons indiquant le nombre de joueurs n'apparaîssent pas
func _ready():
	$CouleurFond/Marges/HBoxContainer/VBoxContainer/MenuOptions/Multi/two.hide() # On cache le bouton "2"
	$CouleurFond/Marges/HBoxContainer/VBoxContainer/MenuOptions/Multi/three.hide() # On cache le bouton "3"
	$CouleurFond/Marges/HBoxContainer/VBoxContainer/MenuOptions/Multi/four.hide() # On cache le bouton "4"



#-------------------------------------------------------------------------------
################## SOLO ########################################################
# Lorsque le joueur appui sur le bouton "SOLO GAME", on lance le maze et on libère le menu d'accueil
# On en profite aussi pour jouer le son de validation du bouton, et la musique de jeu solo
func _on_Solo_pressed():
	get_parent().get_node("MenuMusic").stop()
	get_parent().get_node("Validate").play()
	get_parent().new_maze() # On instancie la maze
	get_parent().kill_accueil(); # On libère l'instance de page d'accueil




#-------------------------------------------------------------------------------
################## MULTI ########################################################
# Lorsque le joueur appui sur le bouton "MULTIJOUEUR", on affiche les boutons indiquant le nombre de joueurs
func _on_Multi_pressed():
	$CouleurFond/Marges/HBoxContainer/VBoxContainer/MenuOptions/Multi/two.show() # On affiche le bouton "2"
	$CouleurFond/Marges/HBoxContainer/VBoxContainer/MenuOptions/Multi/three.show() # On affiche le bouton "3"
	$CouleurFond/Marges/HBoxContainer/VBoxContainer/MenuOptions/Multi/four.show() # On affiche le bouton "4"

#-------------------------------------------------------------------------------
# Si le joueur appuie maintenant sur le bouton "2", on lance une partie à 2 joueurs
# On en profite aussi pour jouer le son de validation du bouton, et la musique de jeu multi
func _on_two_pressed():
	get_parent().get_node("MenuMusic").stop()
	get_parent().get_node("Validate").play()
	get_parent().set_nb_player(2) # On met à jour la variable contenant le nombre de joueurs à instancier dans maze à 2
	get_parent().new_maze() # On instancie la maze avec le bon nombre de joueur
	get_parent().kill_accueil(); # On libère l'instance de page d'accueil

#-------------------------------------------------------------------------------
# Si le joueur appuie maintenant sur le bouton "3", on lance une partie à 3 joueurs
# On en profite aussi pour jouer le son de validation du bouton, et la musique de jeu multi
func _on_three_pressed():
	get_parent().get_node("MenuMusic").stop()
	get_parent().get_node("Validate").play()
	get_parent().set_nb_player(3) # On met à jour la variable contenant le nombre de joueurs à instancier dans maze à 3
	get_parent().new_maze() # On instancie la maze avec le bon nombre de joueur
	get_parent().kill_accueil(); # On libère l'instance de page d'accueil

#-------------------------------------------------------------------------------
# Si le joueur appuie maintenant sur le bouton "4", on lance une partie à 4 joueurs
# On en profite aussi pour jouer le son de validation du bouton, et la musique de jeu multi
func _on_four_pressed():
	get_parent().get_node("MenuMusic").stop()
	get_parent().get_node("Validate").play()
	get_parent().set_nb_player(4) # On met à jour la variable contenant le nombre de joueurs à instancier dans maze à 4
	get_parent().new_maze() # On instancie la maze avec le bon nombre de joueur
	get_parent().kill_accueil(); # On libère l'instance de page d'accueil

# Lorsque la souris entre sur le bouton on joue le son de survol de bouton
func _on_Solo_mouse_entered():
	get_parent().get_node("Select").play()

# Lorsque la souris entre sur le bouton on joue le son de survol de bouton
func _on_Multi_mouse_entered():
	get_parent().get_node("Select").play()

# Lorsque la souris entre sur le bouton on joue le son de survol de bouton
func _on_two_mouse_entered():
	get_parent().get_node("Select").play()

# Lorsque la souris entre sur le bouton on joue le son de survol de bouton
func _on_three_mouse_entered():
	get_parent().get_node("Select").play()

# Lorsque la souris entre sur le bouton on joue le son de survol de bouton
func _on_four_mouse_entered():
	get_parent().get_node("Select").play()
