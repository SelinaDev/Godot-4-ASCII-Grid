extends Control


@onready var term_cell_map: TermCellMap = $TermRoot/MainColumn/TermCellMap


func _ready() -> void:
	_fill_cell_map()


func _fill_cell_map() -> void:
	var ground_cell := TermCell.new(".", Color.SADDLE_BROWN)
	var tree_cell := TermCell.new("♠", Color.WEB_GREEN)
	for x in 500:
		for y in 500:
			if randf() < 0.01:
				term_cell_map.put_cell(tree_cell, Vector2i(x, y))
			else:
				term_cell_map.put_cell(ground_cell, Vector2i(x, y))
	
	var wall_cell := TermCell.new("#", Color.GRAY)
	var empty_cell := TermCell.new(" ")
	for x in range(5, 10):
		for y in range(8, 19):
			if x == 5 or x == 9 or y == 8 or y == 18:
				term_cell_map.put_cell(wall_cell, Vector2i(x, y))
			else:
				term_cell_map.put_cell(empty_cell, Vector2i(x, y))
	var door_cell := TermCell.new("+", Color.YELLOW)
	term_cell_map.put_cell(door_cell, Vector2i(9, 13))
