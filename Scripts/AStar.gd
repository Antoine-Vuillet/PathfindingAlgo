class_name AStar

static func find_path(tilemap: TileMapLayer, start: Vector2i, goal: Vector2i, get_cost_fn: Callable, danger:Vector2i = Vector2i(-100, -100)) -> Array:
	var open_set: Dictionary = { start: 0 }
	var cost_so_far: Dictionary = { start: 0 }
	var came_from: Dictionary = { start: null }

	while open_set.size() > 0:
		var current := _lowest_cost(open_set)
		if current == goal:
			return _reconstruct_path(came_from, start, goal)
		
		open_set.erase(current)
		
		for dir: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor: Vector2i = current + dir
			var terrain : String = tilemap.get_terrain(neighbor)
			var tile_cost :int = get_cost_fn.call(terrain)
			if tile_cost >= 999999:
				continue

			var new_cost : int = cost_so_far[current] + tile_cost

			if not cost_so_far.has(neighbor) or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				came_from[neighbor] = current
				var danger_distance : int = 0
				if(danger != Vector2i(-100,-100)):
					danger_distance = floor(10000/(_manhattan_distance(neighbor,danger)+1)^2)
				var heuristic : int = _manhattan_distance(neighbor, goal)
				open_set[neighbor] = new_cost + heuristic + danger_distance
	
	return []

static func _lowest_cost(open_set: Dictionary) -> Vector2i:
	var best_key :Vector2i = open_set.keys()[0]
	var best_cost :int = open_set[best_key]
	for key in open_set.keys():
		var cost = open_set[key]
		if cost < best_cost:
			best_cost = cost
			best_key = key
	return best_key

static func _reconstruct_path(came_from: Dictionary, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = goal
	while current != null:
		path.append(current as Vector2i)
		current = came_from.get(current)
	path.reverse()
	return path

static func _manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)
