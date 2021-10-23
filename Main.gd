# Main.gd
extends Node2D


# Simple demo that demonstrates how to implement a classic Fog of War effect
# on your 2D game, using a Sprite node (and an optional timer) and a shader.
# 
# The fog sprite's texture is empty initially, but filled from code with a
# black image at the specified size during the initialize() call.
#
# Once a dissolve command is issued at a certain spot, a white & transparent
# dissolve image is blended with the black fog. The shader on the fog texture
# determines the fog color and the parts that need to be transparent.


func _ready():
	# Start fog, let it know how big our world is
	var map_rect = Rect2(Vector2(0, 0), get_viewport().size)
	$Fog.initialize(map_rect)


func _input(event):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.is_pressed():
			$Fog.dissolve(event.position)
