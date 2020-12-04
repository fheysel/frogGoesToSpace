extends MarginContainer
class_name InGameMenuScreen

func _ready():
    var this = ScriptName           # reference to the script
    var cppNode = MyCppNode.new()   # new instance of a class named MyCppNode

    cppNode.queue_free()
