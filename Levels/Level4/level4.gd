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
    # Top vertical corridor (going down from top wall, dead end at bottom)
    _draw_v_corridor(Vector2i(10, 2), 2)
    _draw_v_corridor(Vector2i(13, 2), 2)
    _draw_corner_bl(Vector2i(10, 4))
    _draw_dead_end_down(Vector2i(11, 4))
    _draw_corner_br(Vector2i(13, 4))

    # Left horizontal corridor (going right, dead end at right)
    _draw_h_corridor(Vector2i(1, 6), 6)
    _draw_dead_end_right(Vector2i(7, 6))

    # Right horizontal corridor (going left, dead end at left)
    _draw_dead_end_left(Vector2i(16, 6))
    _draw_h_corridor(Vector2i(17, 6), 6)

    # Bottom vertical corridor (going up from bottom wall, dead end at top)
    _draw_corner_tl(Vector2i(10, 8))
    _draw_dead_end_up(Vector2i(11, 8))
    _draw_corner_tr(Vector2i(13, 8))
    _draw_v_corridor(Vector2i(10, 10), 2)
    _draw_v_corridor(Vector2i(13, 10), 2)


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


## Dead end right: caps a horizontal corridor on the right. 1x2 tile1 column.
func _draw_dead_end_right(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Dead end left: caps a horizontal corridor on the left. 1x2 tile1 column.
func _draw_dead_end_left(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Dead end down: caps a vertical corridor at the bottom. 2x2 tile2/tile1 block.
func _draw_dead_end_down(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(1, 0), 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(1, 1), 1, TILE1)


## Dead end up: caps a vertical corridor at the top. 2x2 tile2/tile1 block.
func _draw_dead_end_up(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(1, 0), 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(1, 1), 1, TILE1)
