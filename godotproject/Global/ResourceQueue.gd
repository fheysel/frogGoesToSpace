# This file was obtained from https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html#doc-background-loading
# The Godot documentation folks provide no warranty/guarantee of functionality or endorsement of our game.
# "Note: this code, in its current form, is not tested in real world scenarios. If you run into any issues, ask for help in one of Godot's community channels."
# The Godot documentation is under the CC-BY 3.0 license: https://creativecommons.org/licenses/by/3.0/
# 2020-01-14: File included verbatim from https://docs.godotengine.org/en/stable/_downloads/db6ccb8924e9f1d36c1319e2813e4808/resource_queue.gd except for this header.
# 2020-02-02: Modified to be single-threaded

var mutex

var queue = []
var pending = {}

func _lock(_caller):
	mutex.lock()

func _unlock(_caller):
	mutex.unlock()

func queue_resource(path, p_in_front = false):
	_lock("queue_resource")
	if path in pending:
		_unlock("queue_resource")
		return
	elif ResourceLoader.has_cached(path):
		var res = ResourceLoader.load(path)
		pending[path] = res
		_unlock("queue_resource")
		return
	else:
		var res = ResourceLoader.load_interactive(path)
		res.set_meta("path", path)
		if p_in_front:
			queue.insert(0, res)
		else:
			queue.push_back(res)
		pending[path] = res
		_unlock("queue_resource")
		return


func cancel_resource(path):
	_lock("cancel_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			queue.erase(pending[path])
		pending.erase(path)
	_unlock("cancel_resource")


func get_progress(path):
	_lock("get_progress")
	var ret = -1
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			ret = float(pending[path].get_stage()) / float(pending[path].get_stage_count())
		else:
			ret = 1.0
	_unlock("get_progress")
	return ret

func _step():
	_lock("step")
	if queue.size() > 0:
		var res = queue[0]
		var ret = res.poll()
		if ret == ERR_FILE_EOF || ret != OK:
			var path = res.get_meta("path")
			if path in pending: # Else, it was already retrieved.
				pending[res.get_meta("path")] = res.get_resource()
			# Something might have been put at the front of the queue while
			# we polled, so use erase instead of remove.
			queue.erase(res)
	_unlock("step")

func is_ready(path):
	# Step our loading
	_step()
	var ret
	_lock("is_ready")
	if path in pending:
		ret = !(pending[path] is ResourceInteractiveLoader)
	else:
		ret = false
	_unlock("is_ready")
	return ret


func _wait_for_resource(_res, path):
	while !is_ready(path):
		_step()
	return pending[path]

func get_resource(path):
	_lock("get_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			var res = pending[path]
			if res != queue[0]:
				var pos = queue.find(res)
				queue.remove(pos)
				queue.insert(0, res)

			res = _wait_for_resource(res, path)
			pending.erase(path)
			_unlock("return")
			return res
		else:
			var res = pending[path]
			pending.erase(path)
			_unlock("return")
			return res
	else:
		_unlock("return")
		return ResourceLoader.load(path)

func start():
	mutex = Mutex.new()
