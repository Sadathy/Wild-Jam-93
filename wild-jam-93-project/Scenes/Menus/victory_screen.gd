extends CanvasLayer

@onready var label_spice: Label = %LabelSPICE
@onready var label_bounty: Label = %LabelBOUNTY
@onready var button_continue: Button = %ButtonCONTINUE

func _ready() -> void:
	button_continue.pressed.connect(on_continue)

func victory() -> void:
	show()
	label_bounty.text = str("You also racked up a bounty of $", Global.bounty, "!")
	label_spice.text = str("Over the course of the run, you managed to gather ", Global.credits, " spice.")

func on_continue() -> void:
	get_parent().main_menu.show()
	Global.bounty = 0
	Global.credits = 0
	get_parent().queue_free()
