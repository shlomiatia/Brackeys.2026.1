extends Node2D

const ROOM_WIDTH := 24
const ROOM_HEIGHT := 14

const TILE1 := Vector2i(2, 3) # lower horizontal wall / vertical wall
const TILE2 := Vector2i(3, 4) # upper horizontal wall

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
    _generate_room()
    _generate_corridor()


func _generate_room() -> void:
    tile_map_layer.clear()
    _draw_h_corridor(Vector2i(1, 0), ROOM_WIDTH - 2)
    _draw_h_corridor(Vector2i(1, ROOM_HEIGHT - 2), ROOM_WIDTH - 2)
    _draw_v_corridor(Vector2i(0, 0), ROOM_HEIGHT)
    _draw_v_corridor(Vector2i(ROOM_WIDTH - 1, 0), ROOM_HEIGHT)


func _generate_corridor() -> void:
    # Top horizontal wall with T-down in the middle
    _draw_h_corridor(Vector2i(1, 3), 20)
    _draw_t_down(Vector2i(11, 3))

    # Left vertical wall as T-right junction
    _draw_t_right(Vector2i(3, 5))

    # Right vertical wall as T-left junction
    _draw_t_left(Vector2i(20, 5))

    # Bottom horizontal wall with corners and T-up in the middle
    _draw_corner_bl(Vector2i(3, 9))
    _draw_h_corridor(Vector2i(4, 9), 16)
    _draw_corner_br(Vector2i(20, 9))
    _draw_t_up(Vector2i(11, 9))


# --- Drawing utilities ---


## Horizontal corridor wall going right: tile2 at pos.y, tile1 at pos.y+1.
func _draw_h_corridor(pos: Vector2i, length: int) -> void:
    for i in range(length):
        tile_map_layer.set_cell(pos + Vector2i(i, 0), 1, TILE2)
        tile_map_layer.set_cell(pos + Vector2i(i, 1), 1, TILE1)


## Vertical corridor wall going down: tile1 column.
func _draw_v_corridor(pos: Vector2i, length: int) -> void:
    for i in range(length):
        tile_map_layer.set_cell(pos + Vector2i(0, i), 1, TILE1)


## Top-left corner: tile2 on top, tile1 below.
func _draw_corner_tl(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Top-right corner: tile2 on top, tile1 below.
func _draw_corner_tr(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Bottom-left corner: tile1 on both rows.
func _draw_corner_bl(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Bottom-right corner: tile1 on both rows.
func _draw_corner_br(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## T-junction down: 2-wide gap in a horizontal wall (corridor branches downward).
func _draw_t_down(pos: Vector2i) -> void:
    tile_map_layer.erase_cell(pos)
    tile_map_layer.erase_cell(pos + Vector2i(1, 0))
    tile_map_layer.erase_cell(pos + Vector2i(0, 1))
    tile_map_layer.erase_cell(pos + Vector2i(1, 1))


## T-junction up: 2-wide gap in a horizontal wall (corridor branches upward).
func _draw_t_up(pos: Vector2i) -> void:
    tile_map_layer.erase_cell(pos)
    tile_map_layer.erase_cell(pos + Vector2i(1, 0))
    tile_map_layer.erase_cell(pos + Vector2i(0, 1))
    tile_map_layer.erase_cell(pos + Vector2i(1, 1))


## T-junction right: vertical wall with gap, corridor branches right.
## Places tile1, empty, tile2, tile1 going down from pos.
func _draw_t_right(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.erase_cell(pos + Vector2i(0, 1))
    tile_map_layer.set_cell(pos + Vector2i(0, 2), 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 3), 1, TILE1)


## T-junction left: vertical wall with gap, corridor branches left.
## Places tile1, empty, tile2, tile1 going down from pos.
func _draw_t_left(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.erase_cell(pos + Vector2i(0, 1))
    tile_map_layer.set_cell(pos + Vector2i(0, 2), 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 3), 1, TILE1)
