extends CanvasLayer

onready var move_state_machine : AnimationNodeStateMachinePlayback = $MovementAnimationTree['parameters/playback']

func _ready():
	move_state_machine.start("out")

func _process(_delta):
	move_state_machine.travel("in")
#	if Input.is_action_just_pressed("jump"):
#		$StyleAnimationPlayer.play("ingame")
#	if Input.is_action_just_pressed("tongue"):
#		$StyleAnimationPlayer.play("inmenu")
#	if Input.is_action_just_pressed("look_down"):
#		move_state_machine.travel("in")
#	if Input.is_action_just_pressed("look_up"):
#		move_state_machine.travel("out")
	pass
