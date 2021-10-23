# Fog.gd
extends Sprite


const INTERVAL = 32 # only draw fog dissolver every X pixels, see dissolve().

var map_rect : Rect2
var fog_img
var dissolve_img
var cleared : Array


# Initialize the fog of war, positioning it and creating an image the size
# of the map to be used as $Fog sprite's texture.
func initialize(_map_rect):
	
	map_rect = _map_rect
	
	# Position fog sprite at map rect's origin
	position = map_rect.position
	centered = false # make sure fog's origin is top left
	dissolve_img = Image.new()
	dissolve_img = preload('res://fog/fog_dissolve.png').get_data()
	
	# Create the fog blocking view. Black blocks sight, white shows what's
	# beneath. Fog color is ultimately determined in shader (through param).
	fog_img = Image.new()
	fog_img.create(int(map_rect.size.x), int(map_rect.size.y), false, Image.FORMAT_RGBA8)
	fog_img.fill(Color(0.0, 0.0, 0.0, 1.0))
	update_texture()
	

# Call every time after dissolving something, the new image should be fed to
# the shader.
func update_texture():
	
	# Set latest fog image to shader
	var fog_tex = ImageTexture.new()
	fog_tex.create_from_image(fog_img)
	material.set_shader_param('fog_texture', fog_tex)
	
	# Set fog texture as this Sprite's texture as well
	texture = fog_tex
	

func dissolve(pos):
	
	# Position dissolve image centered on cursor
	var offset = dissolve_img.get_used_rect().size / 2
	pos -= offset
	
	# clear_pos is not the actual position, but a quick and dirty way
	# of keeping track what areas we dissolved already. Bigger interval means
	# less drawing and less load, but also less detail in dissolving fog.
	# INTERVAL should be adjusted to your specific needs, depending on number
	# of nodes dissolving fog at the same time, size of area that will be
	# dissolved etc.
	var clear_pos = Vector2(int(pos.x / INTERVAL), int(pos.y / INTERVAL))
	
	# Only dissolve here if we hadn't before
	if !clear_pos in cleared:
		
		# Blend fog dissolve image with map size fog image
		var map_pos = Vector2(abs(map_rect.position.x), abs(map_rect.position.y)) + pos
		fog_img.blend_rect(dissolve_img, dissolve_img.get_used_rect(), map_pos)
		
		# Make sure the new image gets used as texture for the fog sprite
		update_texture()
		
		# Don't dissolve fog at this spot again
		cleared.append(clear_pos)
	

# If you have several units dissolving the fog with their movement,
# I've found using an update timer and grouping to be quite effecient.
# Alternatively, if you're dealing with just one unit (i.e. the player)
# using signals after movement may be better.
#
#func _on_UpdateTimer_timeout():
#	var nodes = get_tree().get_nodes_in_group('dissolve_fog')
#	for node in nodes:
#		dissolve(node.position + map_rect.size / 2)
