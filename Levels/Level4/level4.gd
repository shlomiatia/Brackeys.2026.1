extends Node2D

const ROOM_WIDTH := 24
const ROOM_HEIGHT := 14

const TILE1 := Vector2i(2, 3) # lower horizontal wall / vertical wall
const TILE2 := Vector2i(3, 4) # upper horizontal wall

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
    pass
    #_generate_room()
    #_generate_corridor()


func _generate_room() -> void:
    tile_map_layer.clear()
    # Top and bottom horizontal walls
    _draw_h_corridor(Vector2i(1, 0), ROOM_WIDTH - 2)
    _draw_h_corridor(Vector2i(1, ROOM_HEIGHT - 2), ROOM_WIDTH - 2)
    # Left and right vertical walls (full height, overrides tile2 at corners)
    _draw_v_corridor(Vector2i(0, 0), ROOM_HEIGHT)
    _draw_v_corridor(Vector2i(ROOM_WIDTH - 1, 0), ROOM_HEIGHT)


func _generate_corridor() -> void:
    # Top horizontal wall
    _draw_h_corridor(Vector2i(1, 3), 20)

    # Right vertical wall
    _draw_v_corridor(Vector2i(20, 5), 4)

    # Bottom-right corner + bottom horizontal wall + bottom-left corner
    _draw_corner_br(Vector2i(20, 9))
    _draw_h_corridor(Vector2i(4, 9), 16)
    _draw_corner_bl(Vector2i(3, 9))

    # Left vertical wall (gap at y=5-6 for entrance)
    _draw_v_corridor(Vector2i(3, 7), 2)


# --- Drawing utilities ---


## Draws a horizontal corridor wall going right.
## Places tile2 at pos.y and tile1 at pos.y+1, spanning [pos.x .. pos.x+length-1].
func _draw_h_corridor(pos: Vector2i, length: int) -> void:
    for i in range(length):
        tile_map_layer.set_cell(pos + Vector2i(i, 0), 1, TILE2)
        tile_map_layer.set_cell(pos + Vector2i(i, 1), 1, TILE1)


## Draws a vertical corridor wall going down.
## Places tile1 at pos.x, spanning [pos.y .. pos.y+length-1].
func _draw_v_corridor(pos: Vector2i, length: int) -> void:
    for i in range(length):
        tile_map_layer.set_cell(pos + Vector2i(0, i), 1, TILE1)


## Top-left corner: tile2 on top, tile1 below.
## Use where horizontal goes right and vertical goes down.
func _draw_corner_tl(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Top-right corner: tile2 on top, tile1 below.
## Use where horizontal goes left and vertical goes down.
func _draw_corner_tr(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE2)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Bottom-left corner: tile1 on both rows.
## Use where vertical comes from above and horizontal goes right.
func _draw_corner_bl(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)


## Bottom-right corner: tile1 on both rows.
## Use where vertical comes from above and horizontal goes left.
func _draw_corner_br(pos: Vector2i) -> void:
    tile_map_layer.set_cell(pos, 1, TILE1)
    tile_map_layer.set_cell(pos + Vector2i(0, 1), 1, TILE1)
