extends Node2D

@onready var fixture: Node2D = $Fixture
@onready var fixture_2: Node2D = $Fixture2
@onready var fixture_3: Node2D = $Fixture3
@onready var fixture_4: Node2D = $Fixture4
@onready var fixture_5: Node2D = $Fixture5
@onready var turret: CharacterBody2D = $"../Turret"
@onready var turret_2: CharacterBody2D = $"../Turret2"
@onready var turret_3: CharacterBody2D = $"../Turret3"
@onready var turret_4: CharacterBody2D = $"../Turret4"
@onready var turret_5: CharacterBody2D = $"../Turret5"

var turrets: Dictionary = {}

func _ready():
	turrets = {
	fixture:turret,
	fixture_2:turret_2,
	fixture_3:turret_3,
	fixture_4:turret_4,
	fixture_5:turret_5
}

func _process(_delta: float) -> void:
	for fixture in turrets:
		turrets[fixture].global_position = fixture.global_position
	return
