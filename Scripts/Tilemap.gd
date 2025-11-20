extends TileMapLayer

func _ready() -> void:
	print(get_terrain(Vector2i(1,9)))


func get_terrain(cell: Vector2i) -> String:
	var data = get_cell_tile_data(cell)
	if data == null:
		return "None"

	var terrain_type = data.get_custom_data("TerrainType")
	return terrain_type if terrain_type != null else "None"
