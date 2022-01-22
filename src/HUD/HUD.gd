extends Control


################# VARIABLES #########################
var player # Joueur
var loaded:bool = false # Présence du joueur

################ FONCTIONS #########################

#-------------------------------------------------------------------------
# Fonction appelée quand le node entre pour la première fois sur la scène
func _ready():
	$CanvasLayer/VBoxContainer/HBoxContainer/BonusG.visible = false # Le bonus GodMode est invisible
	$CanvasLayer/VBoxContainer/HBoxContainer/BonusL.visible = false # Le bonus Lumière est invisible
	$CanvasLayer/VBoxContainer/HBoxContainer/BonusN.visible = false # Le bonus Nombre de Bombes est invisible
	$CanvasLayer/VBoxContainer/HBoxContainer/BonusP.visible = false # Le bonus Pousser est invisible
	$CanvasLayer/VBoxContainer/HBoxContainer/BonusR.visible = false # Le bonus Portée est invisible
	$CanvasLayer/VBoxContainer/HBoxContainer/BonusV.visible = false # Le bonus Vitesse est invisible

#--------------------------------------------------------------------------
# Fonction appelée pour récupérer le joueur
func getPlayer(p):
	player = p
	loaded=true

#--------------------------------------------------------------------------
# Fonction appelée à tout moment du jeu
func _process(_delta):
	if loaded :
		if is_instance_valid(player): # On vérifie que le joeur est toujours vivant
			if $CanvasLayer/VBoxContainer/Heart/a.is_visible():
				if player.getHeart() ==2:
					$CanvasLayer/VBoxContainer/Heart/a.hide() # Si le joueur a perdu une vie un coeur disparaît
			if $CanvasLayer/VBoxContainer/Heart/b.is_visible():
				if player.getHeart() == 1:
					$CanvasLayer/VBoxContainer/Heart/b.hide() # Si le joueur a perdu une autre vie un deuxième coeur disparaît
			if player.getInvincible() and !$CanvasLayer/VBoxContainer/HBoxContainer/BonusG.is_visible():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusG.visible = true # Si le joueur a obtenu un bonus GodMode on l'affiche
			elif !player.getInvincible() and $CanvasLayer/VBoxContainer/HBoxContainer/BonusG.is_visible():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusG.visible = false # Le bonus n'est plus en activité, il disparaît
			if player.getLumiere() and !$CanvasLayer/VBoxContainer/HBoxContainer/BonusL.is_visible():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusL.visible = true # Si le joueur a obtenu un bonus Lumière on l'affiche
			elif !player.getLumiere() and $CanvasLayer/VBoxContainer/HBoxContainer/BonusL.is_visible():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusL.visible = false # Le bonus n'est plus en activité, il disparaît
			if !$CanvasLayer/VBoxContainer/HBoxContainer/BonusN.is_visible() and player.getNb():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusN.visible = true # Si le joueur a obtenu un bonus Nombre de Bombe on l'affiche
			if !$CanvasLayer/VBoxContainer/HBoxContainer/BonusP.is_visible() and player.getPousse():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusP.visible = true # Si le joueur a obtenu un bonus Pousser on l'affiche
			if !$CanvasLayer/VBoxContainer/HBoxContainer/BonusR.is_visible() and player.getRange():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusR.visible = true # Si le joueur a obtenu un bonus Portée on l'affiche
			if !$CanvasLayer/VBoxContainer/HBoxContainer/BonusV.is_visible() and player.getVite():
				$CanvasLayer/VBoxContainer/HBoxContainer/BonusV.visible = true # Si le joueur a obtenu un bonus Vitesse on l'affiche
		else:
			queue_free() # Si le joueur est mort il n'a plus ni vie ni bonus

