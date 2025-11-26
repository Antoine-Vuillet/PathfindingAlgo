extends CharacterBody2D

@export var tilemap: TileMapLayer
@export var speed: float = 150.0

@export var grass: int = 1
@export var water: int = 3
@export var rock: int = 2
@export var wall: int = 999999

@export var goal_tile: Vector2i = Vector2i(70, 39)
@export var algo : bool = false
var terrain_costs: Dictionary[String, int] = {}

var path: Array = []
var path_index: int = 0
var last_target_tile: Vector2i = goal_tile
@export var is_hunter : bool = false
@export var prey : CharacterBody2D
@export var predator : CharacterBody2D
var hunterCd : float = 2
var currCd : float


func _ready():
	var start_tile = tilemap.local_to_map(position)
	# Initialize terrain_costs using exported values
	terrain_costs = {
		"Grass": grass,
		"Water": water,
		"Rock": rock,
		"Wall": wall
	}
	if(algo):
		path = AStar.find_path(
		tilemap,
		start_tile,
		goal_tile,
		func(t): return _terrain_cost(t))
	else:
		path = Dijkstra.find_path(
		tilemap,
		start_tile,
		goal_tile,
		func(t): return _terrain_cost(t)
		)
	path_index = 0
	if(is_hunter):
		currCd = hunterCd
	# Set character initial position to start_tile
	global_position = tilemap.map_to_local(start_tile)

func _terrain_cost(terrain: String) -> int:
	return terrain_costs.get(terrain, 999999)

func _physics_process(delta):
	if(is_hunter):
		currCd = currCd - delta
		var target_tile = tilemap.local_to_map(prey.position)
		var current_tile = tilemap.local_to_map(global_position)
		if(target_tile == current_tile):
			get_tree().quit()
		if (target_tile != last_target_tile && currCd <=0):
			last_target_tile = target_tile
			if(algo):
				var result = AStar.find_path(tilemap, current_tile, target_tile, func(t): return _terrain_cost(t)) as Array[Vector2i]
				if result:
					path = result as Array[Vector2i]
				else:
					path = []
			else:
				var result = Dijkstra.find_path(tilemap, current_tile, target_tile, func(t): return _terrain_cost(t)) as Array[Vector2i]
				if result:
					path = result as Array[Vector2i]
				else:
					path = []
			path_index = 0
			currCd = hunterCd
	if(!is_hunter):
		var mouse_pos = get_viewport().get_mouse_position()
		var target_tile = tilemap.local_to_map(mouse_pos)
		var danger = tilemap.local_to_map(predator.position)
		if target_tile != last_target_tile:
			last_target_tile = target_tile
			var current_tile = tilemap.local_to_map(global_position)
			if(algo):
				var result = AStar.find_path(tilemap, current_tile, target_tile, func(t): return _terrain_cost(t),danger) as Array[Vector2i]
				if result:
					path = result as Array[Vector2i]
				else:
					path = []
			else:
				var result = Dijkstra.find_path(tilemap, current_tile, target_tile, func(t): return _terrain_cost(t)) as Array[Vector2i]
				if result:
					path = result as Array[Vector2i]
				else:
					path = []
			path_index = 0

	if path.is_empty() or path_index >= path.size():
		velocity = Vector2.ZERO
		return

	var target_pos = tilemap.map_to_local(path[path_index])
	var dir = (target_pos - global_position).normalized()
	var terrain: String = tilemap.get_terrain(tilemap.local_to_map(global_position))
	var modifier = _terrain_cost(terrain)
	velocity = (dir * speed)/modifier
	move_and_slide()

	if global_position.distance_to(target_pos) < 4.0:
		path_index += 1
		if path_index >= path.size():
			velocity = Vector2.ZERO
