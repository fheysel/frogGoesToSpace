extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var path = "user://MonitorData.csv"
var frame_count = 0;

enum MONITOR {
	TIME_FPS ,
	TIME_PROCESS ,
	TIME_PHYSICS_PROCESS ,
	MEMORY_STATIC ,
	MEMORY_DYNAMIC ,
	MEMORY_STATIC_MAX ,
	MEMORY_DYNAMIC_MAX ,
	MEMORY_MESSAGE_BUFFER_MAX ,
	OBJECT_COUNT ,
	OBJECT_RESOURCE_COUNT ,
	OBJECT_NODE_COUNT ,
	OBJECT_ORPHAN_NODE_COUNT ,
	RENDER_OBJECTS_IN_FRAME ,
	RENDER_VERTICES_IN_FRAME ,
	RENDER_MATERIAL_CHANGES_IN_FRAME ,
	RENDER_SHADER_CHANGES_IN_FRAME ,
	RENDER_SURFACE_CHANGES_IN_FRAME ,
	RENDER_DRAW_CALLS_IN_FRAME ,
	RENDER_2D_ITEMS_IN_FRAME ,
	RENDER_2D_DRAW_CALLS_IN_FRAME ,
	RENDER_VIDEO_MEM_USED ,
	RENDER_TEXTURE_MEM_USED ,
	RENDER_VERTEX_MEM_USED ,
	RENDER_USAGE_VIDEO_MEM_TOTAL ,
	PHYSICS_2D_ACTIVE_OBJECTS ,
	PHYSICS_2D_COLLISION_PAIRS ,
	PHYSICS_2D_ISLAND_COUNT ,
	PHYSICS_3D_ACTIVE_OBJECTS ,
	PHYSICS_3D_COLLISION_PAIRS ,
	PHYSICS_3D_ISLAND_COUNT ,
	AUDIO_OUTPUT_LATENCY ,
	MONITOR_MAX ,
}

var MONITOR_NAMES = [
	"TIME_FPS",
	"TIME_PROCESS",
	"TIME_PHYSICS_PROCESS",
	"MEMORY_STATIC",
	"MEMORY_DYNAMIC",
	"MEMORY_STATIC_MAX",
	"MEMORY_DYNAMIC_MAX",
	"MEMORY_MESSAGE_BUFFER_MAX",
	"OBJECT_COUNT",
	"OBJECT_RESOURCE_COUNT",
	"OBJECT_NODE_COUNT",
	"OBJECT_ORPHAN_NODE_COUNT",
	"RENDER_OBJECTS_IN_FRAME",
	"RENDER_VERTICES_IN_FRAME",
	"RENDER_MATERIAL_CHANGES_IN_FRAME",
	"RENDER_SHADER_CHANGES_IN_FRAME",
	"RENDER_SURFACE_CHANGES_IN_FRAME",
	"RENDER_DRAW_CALLS_IN_FRAME",
	"RENDER_2D_ITEMS_IN_FRAME",
	"RENDER_2D_DRAW_CALLS_IN_FRAME",
	"RENDER_VIDEO_MEM_USED",
	"RENDER_TEXTURE_MEM_USED",
	"RENDER_VERTEX_MEM_USED",
	"RENDER_USAGE_VIDEO_MEM_TOTAL",
	"PHYSICS_2D_ACTIVE_OBJECTS",
	"PHYSICS_2D_COLLISION_PAIRS",
	"PHYSICS_2D_ISLAND_COUNT",
	"PHYSICS_3D_ACTIVE_OBJECTS",
	"PHYSICS_3D_COLLISION_PAIRS",
	"PHYSICS_3D_ISLAND_COUNT",
	"AUDIO_OUTPUT_LATENCY",
	"MONITOR_MAX",
]

enum WriteType {
	new,
	append,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	#gets printed once
	var row =  "FRAME_NUMBER,"
	for monitor in range(MONITOR.MONITOR_MAX):
		row += MONITOR_NAMES[monitor]
		row += ","
	WriteLine(row, WriteType.new)
	#To be printed each frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	frame_count += 1
	if frame_count % 5 != 0:
		return
	var parts = PoolStringArray()
	parts.append("%d" % frame_count)
	for monitor in range(MONITOR.MONITOR_MAX):
		parts.append("%f" % (Performance.get_monitor(monitor)))
	WriteLine(parts.join(","), WriteType.append)

var file = null
func WriteLine(line, writeType):
	if !file or !file.is_open():
		file = File.new()
		if (writeType == WriteType.new):
			file.open(path, file.WRITE)
		else:
			file.open(path, file.READ_WRITE)
		file.seek_end(0) # Write at the end of the file
	file.store_line(line)
