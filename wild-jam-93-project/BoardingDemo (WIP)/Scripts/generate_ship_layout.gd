extends TileMapLayer

# This code is known to the state of California to cause cancer

# Parameters
const REGENERATE_IF_FLAW_DETECTED = true

# Packed Scenes
const lootbox_scene = preload("../Scenes/loot_box.tscn")
const enemy_scene = preload("../Scenes/boarding_enemy.tscn")

@export var loot_box_parent : Node2D
@export var enemy_parent : Node2D

# State variables
@onready var pointer : Vector2i
@onready var hallway_placement_queue : Array[Vector2i]
@onready var roomcount : int = 0
@onready var timer : int = 0
@onready var need_regenerate : bool = false

# Constants
const FLOOR_TILE : Vector2i = Vector2i(0,0)
const DOOR_TILE : Vector2i = Vector2i(4,0)
const WALL_TILE : Vector2i = Vector2i(1,0)
const CORNER_TILE : Vector2i = Vector2i(2,0)
const INVERTED_CORNER_TILE : Vector2i = Vector2i(3,0)
const BANDAID : Vector2i = Vector2i(5,0)
const EMPTY_TILE : Vector2i = Vector2i(-1,-1)
const WALLS_PLACEHOLDER : Vector2i = (Vector2i(100,100))

enum TileTransform {
	ROTATE_0 = 0,
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

func _ready() -> void:
	Engine.print_error_messages = false
	generate()
	Engine.print_error_messages = true
	#place_room(Vector2i(0,0), 7, 7)
	pass # Replace with function body.

#func _physics_process(delta: float) -> void:
	#if timer <= 0:
		#timer = 0
		#if not hallway_placement_queue.is_empty():
			#set_cell(hallway_placement_queue.pop_front(), 0, FLOOR_TILE)
	#timer -= 1
	#if Input.is_action_just_pressed("TEST"):
		#hallway_placement_queue = []
		#roomcount = 0
		#clear()
		#generate()

func generate():
	for child : Node2D in loot_box_parent.get_children():
		child.queue_free()
	for child : Node2D in enemy_parent.get_children():
		child.queue_free()
	need_regenerate = false
	place_room(Vector2i(0,0), 5, 5)
	place_walls()
	place_corners()
	align_tiles()
	clean_mistakes()
	align_tiles()
	place_entities()
	if need_regenerate and REGENERATE_IF_FLAW_DETECTED:
		#print("there was a flaw, regenerating...")
		hallway_placement_queue = []
		roomcount = 0
		clear()
		generate()

func place_room(center_position: Vector2i, x_scale: int, y_scale: int):
	@warning_ignore("integer_division")
	var room_top_left_corner = Vector2i(center_position.x - (x_scale / 2), center_position.y - (y_scale / 2))
	for y in range(y_scale):
		for x in range(x_scale):
			place_cell(room_top_left_corner + Vector2i(x, y), FLOOR_TILE)
	#@warning_ignore("integer_division")
	#var left_door_coord : Vector2i = room_top_left_corner+Vector2i(-1, y_scale / 2)
	@warning_ignore("integer_division")
	var right_door_coord : Vector2i = room_top_left_corner+Vector2i(x_scale, y_scale / 2)
	@warning_ignore("integer_division")
	var up_door_coord : Vector2i = room_top_left_corner+Vector2i(x_scale / 2, -1)
	@warning_ignore("integer_division")
	var down_door_coord : Vector2i = room_top_left_corner+Vector2i(x_scale / 2, y_scale)
	#place_cell(left_door_coord, DOOR_TILE, TileTransform.ROTATE_270)
	#place_cell(right_door_coord, DOOR_TILE, TileTransform.ROTATE_90)
	#place_cell(up_door_coord, DOOR_TILE)
	#place_cell(down_door_coord, DOOR_TILE, TileTransform.ROTATE_180)
	#generate_winding_path(left_door_coord, Vector2i.LEFT)
	roomcount += 1
	if roomcount < 10:
		generate_winding_path(right_door_coord, Vector2i.RIGHT)
		generate_winding_path(up_door_coord, Vector2i.UP)
		generate_winding_path(down_door_coord, Vector2i.DOWN)

func generate_winding_path(coord : Vector2i, initial_direction : Vector2i):
	var pointer : Vector2i = coord
	var current_direction : Vector2i = initial_direction
	var queue_cell_placements : Array = []
	place_cell(pointer, FLOOR_TILE)
	for i in range(randi_range(1,3)):
		for j in range(randi_range(3,10)):
			pointer += current_direction
			if get_cell_atlas_coords(pointer) == FLOOR_TILE or get_cell_atlas_coords(pointer) == DOOR_TILE:
				return
			queue_cell_placements.append(pointer)
		current_direction = random_direction()
	for cell_coord in queue_cell_placements:
		place_cell(cell_coord, FLOOR_TILE)
	place_room(pointer, randi_range(3,10), randi_range(3,10))
		

#func _generate_winding_path(coord : Vector2i, startDirection) -> Array:
	#pointer = coord
	#var cells_to_set : Array = []
	#var original_pointer_position : Vector2 = pointer
	#place_cell(pointer, FLOOR_TILE)
	#var direction : Vector2i = directions.pick_random()
	#for i in range(randi_range(3,10)):
		#pointer += direction
		#if get_cell_atlas_coords(pointer) == FLOOR_TILE:
			#pointer = original_pointer_position
		#cells_to_set.append(pointer)
	#for cell_coord : Vector2i in cells_to_set:
		#place_cell(cell_coord, FLOOR_TILE)
	#return cells_to_set

func place_cell(coord: Vector2i, tile_type: Vector2i, orientation: TileTransform=TileTransform.ROTATE_0):
	#haltlway_placement_queue.append(coord)
	set_cell(coord, 0, tile_type, orientation)
	
func random_direction() -> Vector2i:
	return [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT].pick_random()

func place_walls():
	var occupied_cells : Array[Vector2i] = get_used_cells()
	var set_unoccupied_cells : Dictionary = {}
	for cell_coord in occupied_cells:
		if get_cell_atlas_coords(cell_coord + Vector2i.UP) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.UP] = null
		if get_cell_atlas_coords(cell_coord + Vector2i.DOWN) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.DOWN] = null
		if get_cell_atlas_coords(cell_coord + Vector2i.LEFT) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.LEFT] = null
		if get_cell_atlas_coords(cell_coord + Vector2i.RIGHT) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.RIGHT] = null
			
		if get_cell_atlas_coords(cell_coord + Vector2i.RIGHT + Vector2i.UP) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.RIGHT + Vector2i.UP] = null
		if get_cell_atlas_coords(cell_coord + Vector2i.RIGHT + Vector2i.DOWN) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.RIGHT + Vector2i.DOWN] = null
		if get_cell_atlas_coords(cell_coord + Vector2i.LEFT + Vector2i.UP) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.LEFT + Vector2i.UP] = null
		if get_cell_atlas_coords(cell_coord + Vector2i.LEFT + Vector2i.DOWN) == EMPTY_TILE:
			set_unoccupied_cells[cell_coord + Vector2i.LEFT + Vector2i.DOWN] = null
	for cell_cord in set_unoccupied_cells.keys():
		place_cell(cell_cord, WALL_TILE)
	for cell_coord in set_unoccupied_cells.keys():
		if get_cell_atlas_coords(cell_coord + Vector2i.RIGHT) == FLOOR_TILE and get_cell_atlas_coords(cell_coord + Vector2i.LEFT) == FLOOR_TILE:
			place_cell(cell_coord, FLOOR_TILE)
		elif get_cell_atlas_coords(cell_coord + Vector2i.UP) == FLOOR_TILE and get_cell_atlas_coords(cell_coord + Vector2i.DOWN) == FLOOR_TILE:
			place_cell(cell_coord, FLOOR_TILE)
		elif get_cell_atlas_coords(cell_coord + Vector2i.LEFT) == WALLS_PLACEHOLDER and get_cell_atlas_coords(cell_coord + Vector2i.RIGHT) == WALLS_PLACEHOLDER:
			place_cell(cell_coord, WALL_TILE)
		#else:
		#	place_cell(cell_coord, DOOR_TILE)

func place_corners() -> void:
	var queue_place_corners : Array[Vector2i] = []
	var queue_place_inverted_corners : Array[Vector2i] = []
	var occupied_cells : Array[Vector2i] = get_used_cells()
	for cell_coord : Vector2i in occupied_cells:
		if get_cell_atlas_coords(cell_coord) != WALL_TILE:
			continue
		var is_corner_status : int = _is_corner_wall(cell_coord)
		if is_corner_status == 1:
			queue_place_corners.append(cell_coord)
		elif is_corner_status == 2:
			queue_place_inverted_corners.append(cell_coord)
	for cell_coord : Vector2i in queue_place_corners:
		place_cell(cell_coord, CORNER_TILE)
	for cell_coord : Vector2i in queue_place_inverted_corners:
		place_cell(cell_coord, INVERTED_CORNER_TILE)

func _is_corner_wall(coord : Vector2i) -> int:
	if (get_cell_atlas_coords(coord) != WALL_TILE):
		return 0
	var wall_count : int = 0
	var floor_count : int = 0
	for cell_coord : Vector2i in get_surrounding_cells(coord):
		if get_cell_atlas_coords(cell_coord) == WALL_TILE:
			wall_count += 1
		elif get_cell_atlas_coords(cell_coord) == FLOOR_TILE:
			floor_count += 1
	if wall_count == 2 and floor_count == 2:
		return 1
	if wall_count == 2 and floor_count == 0:
		return 2
	return 0

func align_tiles() -> void:
	# Walls
	for cell_coord : Vector2i in get_used_cells():
		if get_cell_atlas_coords(cell_coord) == WALL_TILE:
			# UP
			if get_cell_atlas_coords(cell_coord+Vector2i.DOWN) == EMPTY_TILE:
				place_cell(cell_coord, WALL_TILE, TileTransform.ROTATE_180)
			# RIGHT
			if get_cell_atlas_coords(cell_coord+Vector2i.LEFT) == EMPTY_TILE:
				place_cell(cell_coord, WALL_TILE, TileTransform.ROTATE_270)
			# LEFT
			if get_cell_atlas_coords(cell_coord+Vector2i.RIGHT) == EMPTY_TILE:
				place_cell(cell_coord, WALL_TILE, TileTransform.ROTATE_90)
		# Corners
		elif get_cell_atlas_coords(cell_coord) == CORNER_TILE: # this need to be fixed to use diagonally adjacent empty tiles
			#if _tile_is_wall_of_some_sort(cell_coord+Vector2i.RIGHT):
				#if _tile_is_wall_of_some_sort(cell_coord+Vector2i.UP):
					#place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_90)
				#if _tile_is_wall_of_some_sort(cell_coord+Vector2i.DOWN):
					#place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_180)
			#elif _tile_is_wall_of_some_sort(cell_coord+Vector2i.LEFT):
				#if _tile_is_wall_of_some_sort(cell_coord+Vector2i.DOWN):
					#place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_270)
				#if _tile_is_wall_of_some_sort(cell_coord+Vector2i.UP):
					#place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_0)
			if _tile_is_empty(cell_coord+Vector2i(1,1)):
				place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_180)
			elif _tile_is_empty(cell_coord+Vector2i(-1,1)):
				place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_270)
			elif _tile_is_empty(cell_coord+Vector2i(1,-1)):
				place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_90)
			elif _tile_is_empty(cell_coord+Vector2i(-1,-1)):
				place_cell(cell_coord, CORNER_TILE, TileTransform.ROTATE_0)
		# Inverted Corners
		elif get_cell_atlas_coords(cell_coord) == INVERTED_CORNER_TILE:
			if get_cell_atlas_coords(cell_coord+Vector2i.RIGHT) != EMPTY_TILE:
				if get_cell_atlas_coords(cell_coord+Vector2i.UP) != EMPTY_TILE:
					place_cell(cell_coord, INVERTED_CORNER_TILE, TileTransform.ROTATE_180)
				if get_cell_atlas_coords(cell_coord+Vector2i.DOWN) != EMPTY_TILE:
					place_cell(cell_coord, INVERTED_CORNER_TILE, TileTransform.ROTATE_270)
				#place_cell(cell_coord, WALL_TILE, TileTransform.ROTATE_270)
			elif get_cell_atlas_coords(cell_coord+Vector2i.LEFT) != EMPTY_TILE and get_cell_atlas_coords(cell_coord+Vector2i.UP) != EMPTY_TILE:
				place_cell(cell_coord, INVERTED_CORNER_TILE, TileTransform.ROTATE_90)

func clean_mistakes():
	for cell_coord : Vector2i in get_used_cells():
		# detect invalid walls
		if get_cell_atlas_coords(cell_coord) == WALL_TILE:
			# if not adjacent to an empty tile
			if not (get_cell_atlas_coords(cell_coord+Vector2i.RIGHT) == EMPTY_TILE or get_cell_atlas_coords(cell_coord+Vector2i.LEFT) == EMPTY_TILE or get_cell_atlas_coords(cell_coord+Vector2i.UP) == EMPTY_TILE or get_cell_atlas_coords(cell_coord+Vector2i.DOWN) == EMPTY_TILE):
				# check if it should be a corner tile instead
				if _tile_is_empty(cell_coord+Vector2i(1,1)) or _tile_is_empty(cell_coord+Vector2i(-1,1)) or _tile_is_empty(cell_coord+Vector2i(1,-1)) or _tile_is_empty(cell_coord+Vector2i(-1,-1)):
					place_cell(cell_coord, CORNER_TILE)
				else:
					# otherwise replace it with a floor tile
					place_cell(cell_coord, FLOOR_TILE)
			elif (_tile_is_empty(cell_coord+Vector2i(-1,-1)) and _tile_is_empty(cell_coord+Vector2i(1,1))) or (_tile_is_empty(cell_coord+Vector2i(1,-1)) and _tile_is_empty(cell_coord+Vector2i(-1,1))):
				# if adjacent to two empty tiles, turn into a bandaid
				place_cell(cell_coord, BANDAID)
				need_regenerate = true
		elif get_cell_atlas_coords(cell_coord) == CORNER_TILE:
			# if not diagonally adjacent to an empty tile
			if not (_tile_is_empty(cell_coord+Vector2i.RIGHT+Vector2i.UP) or _tile_is_empty(cell_coord+Vector2i.LEFT+Vector2i.UP) or _tile_is_empty(cell_coord+Vector2i.LEFT+Vector2i.DOWN) or _tile_is_empty(cell_coord+Vector2i.DOWN+Vector2i.RIGHT)):
				place_cell(cell_coord, FLOOR_TILE) # get rid of it
			# If diagonally adjacent to two empty tiles
			elif (_tile_is_empty(cell_coord+Vector2i(-1,-1)) and _tile_is_empty(cell_coord+Vector2i(1,1))) or (_tile_is_empty(cell_coord+Vector2i(1,-1)) and _tile_is_empty(cell_coord+Vector2i(-1,1))):
				place_cell(cell_coord, BANDAID)
				need_regenerate = true

func place_entities():
	for cell_coord : Vector2i in get_used_cells():
		if get_cell_atlas_coords(cell_coord) == FLOOR_TILE:
			if randf_range(0, 100) < 3:
				var new_lootbox : Node2D = lootbox_scene.instantiate()
				new_lootbox.global_position = (cell_coord) * 64
				loot_box_parent.add_child(new_lootbox)
			elif randf_range(0, 100) <= 2:
				var new_enemy : Node2D = enemy_scene.instantiate()
				new_enemy.global_position = (cell_coord) * 64
				enemy_parent.add_child(new_enemy)
				

func _tile_is_wall_of_some_sort(cell_cord : Vector2i) -> bool:
	return get_cell_atlas_coords(cell_cord) in [CORNER_TILE, INVERTED_CORNER_TILE, WALL_TILE]

func _tile_is_empty(cell_coord : Vector2i):
	return get_cell_atlas_coords(cell_coord) == Vector2i(-1, -1)
