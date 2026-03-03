extends Node2D

@onready var player: CharacterBody2D = $PlayerCharacter
@onready var glitch_effects = $GlitchLayer

var platforms: Array[Node] = []

func _ready() -> void:
	# Collect platform nodes for glitch effects
	for child in $Platforms.get_children():
		platforms.append(child)
	if glitch_effects and glitch_effects.has_method("set_platforms"):
		glitch_effects.set_platforms(platforms)
	if glitch_effects and glitch_effects.has_method("set_player"):
		glitch_effects.set_player(player)
