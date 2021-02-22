extends Position2D

onready var label = $TextPos/RichTextLabel
onready var tween = $TextPos/Tween

export (String) var text = "default" #external var

func _ready():
	 label.set_bbcode(text)
	 label.set_percent_visible(0.0)


func _on_PlayerDetector_body_entered(body):	
	if body.name == "Player":	
		label.set_percent_visible(1.0)	
		#text tip fade in
		tween.start()
		tween.interpolate_property($TextPos, 'scale', $TextPos.scale, Vector2(1,1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)

		
func _on_PlayerDetector_body_exited(body):	
	if body.name == "Player":
		#text tip fade out
		tween.start()
		tween.interpolate_property($TextPos, 'scale', Vector2(1,1), Vector2(0.1,0.1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
