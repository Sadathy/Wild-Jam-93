extends Node2D


@export var band_one_size: int = 2
@export var band_two_size: int = 3
@export var band_three_size: int = 2

@onready var background: Polygon2D = %Background

var max_x = 1050 + 75
var min_x = -100 - 75
var max_y = 360
var min_y = -360

var main_menu = null

var band_one_x: float
var band_two_x: float
var band_three_x: float
var stage_index: int = 0

var no_stages: int

var selector

const ALIEN_WORLD_ART = preload("uid://fjbf5jasln60")
const ASTEROID_FIELD_ART = preload("uid://dgqy4oc6louch")
const CYBER_WORLD_ART = preload("uid://cw4q7yhtgdjot")
const DESERT_WORLD_ART = preload("uid://jl43kvauxqum")
const NEBULA_ART = preload("uid://b3qkrqjlkh0oa")
const STATION_ART = preload("uid://w0gfk5ytgusn")

const STAGE_SELECTOR = preload("uid://kbx8xem7xbyt")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")
const LEVEL_SELECT_SHIP = preload("uid://cj2erk75s1vp0")

@onready var select_camera: Camera2D = %SelectCamera


const stage_type_data: Dictionary = {
	"station": {
		"art": STATION_ART,
		"name": "Space Station",
		"details": "- Spend spice to lower your bounty
		- Spend spice to repair your hull
		- Non-combat zone, no chance to get more spice",
		"level": Global.LEVEL_STATION
	},
	"nebula": {
		"art": NEBULA_ART,
		"name": "Nebula",
		"details": "- Small map, you'll get boxed in fast
		- Less enemies, but also less spice available
		- No asteroids",
		"level": Global.LEVEL_NEBULA
	},
	"desert": {
		"art": DESERT_WORLD_ART,
		"name": "Desert World",
		"details": "- Lots of natural spice blooms
		- Well patrolled by the navy, expect more navy ships
		- Fewer asteroids",
		"level": Global.LEVEL_DESERT
	},
	"cyber": {
		"art": CYBER_WORLD_ART,
		"name": "Cyber World",
		"details": "- Expect lots of snipers defending their home
		- Extra cargo ships traverse this industrialised area
		- Good rewards, but you'll build a bounty fast",
		"level": Global.LEVEL_CYBER
	},
	"asteroid": {
		"art": ASTEROID_FIELD_ART,
		"name": "Asteroid Belt",
		"details": "- LOADS OF ASTEROIDS
		- I mean seriously, watch out for the asteroids
		- Did I mention there were more asteroids?",
		"level": Global.LEVEL_ASTEROID
	},
	"alien": {
		"art": ALIEN_WORLD_ART,
		"name": "Alien World",
		"details": "- Expect more spinners here, defending their home
		- The navy is reluctant to patrol, lowering the relevance of your bounty
		- Cargo ships are also reluctant, you'll be getting your spice from combat",
		"level": Global.LEVEL_ALIEN
	}
}

var stages: Dictionary = {}
var current_stage: int = 0
var starting_stage: bool = false

@onready var victory_screen: CanvasLayer = %VictoryScreen
@onready var button_quit_to_menu: Button = %ButtonQuitToMenu
@onready var general_level_ui: CanvasLayer = %GeneralLevelUI

func _ready() -> void:
	button_quit_to_menu.pressed.connect(victory_screen.on_continue)
	
	var p_arr = PackedVector2Array([Vector2(min_x, max_y), Vector2(max_x, max_y), Vector2(max_x, min_y), Vector2(min_x, min_y)])
	background.polygon = p_arr

	band_one_x = (max_x - 100) / 3
	band_two_x = band_one_x * 2
	band_three_x = band_one_x * 3
	
	no_stages = band_one_size + band_two_size + band_three_size
	
	make_constellation()
	
	selector = LEVEL_SELECT_SHIP.instantiate()
	selector.position = stages[0]["position"]
	add_child(selector)
	
	current_stage = 0
	starting_stage = false
	
func on_stage_clicked(stage_id) -> void:
	if starting_stage == true:
		return
	print("Detected a click on stage", stage_id)
	if current_stage == 0:
		var linked_to_stage = false
		for i in band_one_size:
			if stage_id == stages[0][str("link", i + 1)]:
				linked_to_stage = true
		print("Was the clicked stage linked to current?: ", linked_to_stage)
		if linked_to_stage == true:
			AudioManager.play(preload("res://Assets/Audio/obsydianx/confirm_style_2_003.wav"))
			start_stage(stage_id)
			return
	if current_stage > 0:
		var linked_to_stage = false
		if stage_id == stages[current_stage]["link_one"]: linked_to_stage = true
		if stage_id == stages[current_stage]["link_two"]: linked_to_stage = true
		if linked_to_stage == true:
			AudioManager.play(preload("res://Assets/Audio/obsydianx/confirm_style_2_003.wav"))
			start_stage(stage_id)
			return
	AudioManager.play(preload("res://Assets/Audio/obsydianx/back_style_2_001.wav"))

func start_stage(stage_id) -> void:
	print("Attempted to start stage id: ", stage_id)
	selector.show_flying()
	print("passing position: ", stages[stage_id]["position"])
	selector.set_target(stages[stage_id]["position"])
	await selector.reached_next_stage
	print("Reached the next stage")
	AudioManager.stop_music()
	hide()
	general_level_ui.hide()
	Global.new_level(stage_type_data[stages[stage_id]["type"]]["level"])
	await Global.level.level_complete
	toggle_indicator_fades(stage_id)
	current_stage = stage_id
	select_camera.make_current()
	show()
	general_level_ui.show()
	if current_stage > no_stages - band_three_size:
		victory()

func toggle_indicator_fades(next_stage) -> void:
	if current_stage == 0:
		for i in band_one_size:
			stages[0][str("link", i + 1, "_LINE")].modulate = Color(1, 1, 1, 0.25)
	else:
		stages[current_stage]["link_one_LINE"].modulate = Color(1, 1, 1, 0.25)
		stages[current_stage]["link_two_LINE"].modulate = Color(1, 1, 1, 0.25)
	stages[next_stage]["link_one_LINE"].modulate = Color(1, 1, 1, 1)
	stages[next_stage]["link_two_LINE"].modulate = Color(1, 1, 1, 1)
	
func victory() -> void:
	# Go through and queue free all our stages and our stage selector
	selector.queue_free()
	general_level_ui.queue_free()
	for i in no_stages + 1:
		stages[i]["stage"].queue_free()
	victory_screen.victory()
	

func make_constellation() -> void:
	# Generate a constellation of levels
	stage_index = 0
	stages[stage_index] = create_stage(stage_index)
	for i in no_stages:
		var stage_index = i + 1
		if stage_index <= band_one_size:
			make_band_one_stage(stage_index)
		if stage_index > band_one_size and stage_index <= (band_two_size + band_one_size):
			print("Made a stage two")
			make_band_two_stage(stage_index)
		if stage_index > (band_one_size + band_two_size):
			print("Made a stage three")
			make_band_three_stage(stage_index)
			
	# Now loop through and link everything up to a number of follow on points logically
	for i in band_one_size:
		stages[0][str("link", i + 1)] = i + 1
	for i in no_stages:
		var stage_index = i + 1
		if stage_index <= band_one_size:
			var desired_link_one = stage_index + band_one_size
			var desired_link_two = stage_index + band_one_size + 1
			if desired_link_one > band_one_size + band_two_size:
				stages[stage_index]["link_one"] = desired_link_one - 1
			else:
				stages[stage_index]["link_one"] = desired_link_one
			if desired_link_two > band_one_size + band_two_size:
				stages[stage_index]["link_two"] = -1
			else:
				stages[stage_index]["link_two"] = desired_link_two
		if stage_index > band_one_size and stage_index <= band_one_size + band_two_size:
			var desired_link_one = stage_index + band_two_size
			var desired_link_two = stage_index + band_two_size + 1
			if desired_link_one > no_stages or desired_link_one < band_one_size + band_two_size:
				stages[stage_index]["link_one"] = desired_link_one - 1
			else:
				stages[stage_index]["link_one"] = desired_link_one
			if desired_link_two > no_stages or desired_link_two < band_one_size + band_two_size:
				stages[stage_index]["link_two"] = -1
			else:
				stages[stage_index]["link_two"] = desired_link_two
	
	# Now loop through every stage and draw a link line from that stage to the stages it's linked to
	for i in band_one_size:
		var new_line = TARGET_LINE.instantiate()
		new_line.set_point_position(0, stages[0]["position"])
		new_line.set_point_position(1, stages[stages[0][str("link", i + 1)]]["position"])
		add_child(new_line)
		new_line.modulate = Color(1, 1, 1, 1)
		stages[0][str("link", i + 1, "_LINE")] = new_line
	for i in no_stages:
		var stage_index = i + 1
		if stage_index <= band_one_size + band_two_size:
			var line_target = stages[stage_index]["link_one"]
			if line_target != -1:
				var new_line = TARGET_LINE.instantiate()
				new_line.set_point_position(0, stages[stage_index]["position"])
				new_line.set_point_position(1, stages[line_target]["position"])
				add_child(new_line)
				new_line.modulate = Color(1, 1, 1, .25)
				stages[stage_index]["link_one_LINE"] = new_line
			line_target = stages[stage_index]["link_two"]
			if line_target != -1:
				var new_line = TARGET_LINE.instantiate()
				new_line.set_point_position(0, stages[stage_index]["position"])
				new_line.set_point_position(1, stages[line_target]["position"])
				add_child(new_line)
				new_line.modulate = Color(1, 1, 1, .25)
				stages[stage_index]["link_two_LINE"] = new_line
			
func make_band_one_stage(new_index: int) -> void:
	# Roll for y position
	var y_range = ((max_y - 50) - (min_y + 50)) / band_one_size
	var y_pos = randf_range(100, y_range)
	y_pos -= y_range * (new_index - 1)
	var stage_vector = Vector2(band_one_x, y_pos)
	# Add a bit of variance to make the layout slightly more interesting
	stage_vector.x += randf_range(-75, 75)
	# In band one, the stages can be nebulas, asteroid fields or desert worlds
	var stage_roll = randi_range(1, 3)
	if stage_roll == 1:
		stages[new_index] = create_stage(new_index, "alien", stage_vector)
	if stage_roll == 2:
		stages[new_index] = create_stage(new_index, "cyber", stage_vector)
	if stage_roll == 3:
		stages[new_index] = create_stage(new_index, "desert", stage_vector)
		
func make_band_two_stage(new_index: int) -> void:
	# Roll for y position
	var y_range = ((max_y - 50) - (min_y + 50)) / band_two_size
	var y_pos = randf_range(100, y_range)
	y_pos -= y_range * (new_index - (1 + band_one_size))
	var stage_vector = Vector2(band_two_x, y_pos)
	# Add a bit of variance to make the layout slightly more interesting
	stage_vector.x += randf_range(-75, 75)
	# In band two, the stages can be deserts, alien worlds or cyber worlds
	var stage_roll = randi_range(1, 3)
	if stage_roll == 1:
		stages[new_index] = create_stage(new_index, "desert", stage_vector)
	if stage_roll == 2:
		stages[new_index] = create_stage(new_index, "nebula", stage_vector)
	if stage_roll == 3:
		stages[new_index] = create_stage(new_index, "asteroid", stage_vector)

func make_band_three_stage(new_index: int) -> void:
	# Roll for y position
	var y_range = ((max_y - 50) - (min_y + 50)) / band_three_size
	var y_pos = randf_range(100, y_range)
	y_pos -= y_range * (new_index - (1 + band_one_size + band_two_size))
	var stage_vector = Vector2(band_three_x, y_pos)
	# Add a bit of variance to make the layout slightly more interesting
	stage_vector.x += randf_range(-75, 75)
	# In band three, the stages can be anything except stations!
	var stage_roll = randi_range(1, 5)
	if stage_roll == 1:
		stages[new_index] = create_stage(new_index, "nebula", stage_vector)
	if stage_roll == 2:
		stages[new_index] = create_stage(new_index, "asteroid", stage_vector)
	if stage_roll == 3:
		stages[new_index] = create_stage(new_index, "desert", stage_vector)
	if stage_roll == 4:
		stages[new_index] = create_stage(new_index, "alien", stage_vector)
	if stage_roll == 5:
		stages[new_index] = create_stage(new_index, "cyber", stage_vector)
		
func create_stage(new_index: int, new_type: String = "station", new_position: Vector2 = Vector2.ZERO) -> Dictionary:
	var new_stage = STAGE_SELECTOR.instantiate()
	new_stage.position = new_position
	new_stage.id = new_index
	new_stage.display_name = stage_type_data[new_type]["name"]
	new_stage.details = stage_type_data[new_type]["details"]
	new_stage.stage_clicked.connect(on_stage_clicked)
	add_child(new_stage)
	new_stage.sprite.texture = stage_type_data[new_type]["art"]
	
	var new_data = {
		"stage": new_stage,
		"type": new_type,
		"position": new_position
		}
		
	return new_data
