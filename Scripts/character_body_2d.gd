extends CharacterBody2D

@export var tilemap: TileMapLayer
@export var speed: float = 150.0

@export var grass: int = 1
@export var water: int = 3
@export var rock: int = 2

# Starting and goal tiles in map coordinates
@export var goal_tile: Vector2i = Vector2i(70, 39)
@export var predator : CharacterBody2D
@export var prey : CharacterBody2D
@export var predCd: float = 1
var currCD = 0
# Character-specific terrain costs
var terrain_costs: Dictionary[String, int] = {}
# Path found by Dijkstra
var path: Array = []
var path_index: int = 0
var last_target_tile: Vector2i = goal_tile

func _ready():
	# Initialize terrain_costs using exported values
	terrain_costs = {
		"Grass": grass,
		"Water": water,
		"Rock": rock
	}
	var enemy_pos
	var current_tile = tilemap.local_to_map(global_position)
	if(predator):
		enemy_pos = tilemap.local_to_map(predator.position)
		path = AStar.find_path(tilemap,current_tile,enemy_pos,goal_tile,func(t): return _terrain_cost(t))
	if(prey):
		enemy_pos = tilemap.local_to_map(prey.position)
		path = Dijkstra.find_path(tilemap,current_tile,enemy_pos,func(t): return _terrain_cost(t))
	path_index = 0

	global_position = tilemap.map_to_local(current_tile)

func _terrain_cost(terrain: String) -> int:
	return terrain_costs.get(terrain, 999999)

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var target_tile = tilemap.local_to_map(mouse_pos)
	var enemy_pos
	var current_tile = tilemap.local_to_map(global_position)
	if predator:
		currCD -= delta
		var at_tile_center := global_position.distance_to(tilemap.map_to_local(current_tile)) < 8.0
		if currCD <= 0 and at_tile_center:
			print("Math")
			enemy_pos = tilemap.local_to_map(predator.position)
			var result = AStar.find_path(tilemap, current_tile, enemy_pos, target_tile, func(t): return _terrain_cost(t)) as Array[Vector2i]
			currCD = predCd
			if result:
				path = result
			else:
				path = []
			path_index = 0
	if(prey):
		enemy_pos = tilemap.local_to_map(prey.position)
		if target_tile != last_target_tile:
			last_target_tile = target_tile
			var result = Dijkstra.find_path(tilemap, current_tile, enemy_pos, func(t): return _terrain_cost(t)) as Array[Vector2i]
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
	velocity = dir * speed
	move_and_slide()

	if global_position.distance_to(target_pos) < 4.0:
		path_index += 1
		if path_index >= path.size():
			velocity = Vector2.ZERO
