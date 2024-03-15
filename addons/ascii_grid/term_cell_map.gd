class_name TermCellMap
extends TermContainer

## A node holding a grid of [TermCell]s that can be edited directly.
##
## This node holds a grid of [TermCell]s, that automatically get drawn to the buffer.
## Can be used either to directly manipulate the grid, or, e.g., as a background layer that does not change a lot.

var _grid: Dictionary = {}
var _draw_grid: Dictionary
var _recalculate_draw_grid := false

## Offset to be applied to the grid when drawing.
## Per default drawing of the grid starts at [0, 0] in the top left corner. The [property TermCellMap.offset] can move this point.
## This could be used to implement, e.g., a camera system.
@export var offset: Vector2i = Vector2i.ZERO:
	set(value):
		offset = value
		_redraw_required = true


## Clears the internal grid of the node.
func clear() -> void:
	_grid = {}
	_redraw_required = true

## Places the provided [parameter cell] at the specified point in the grid.
func put_cell(cell: TermCell, at: Vector2i) -> void:
	_grid[at] = cell
	_redraw_required = true
	_recalculate_draw_grid = true

## Returns the cell stored at the specified position.
## Returns [code]null[/code] if no cell is set at that position.
func get_cell(at: Vector2i) -> TermCell:
	return _grid.get(at, null)


func _blit_self_under(buffer: TermBuffer) -> void:
	if _recalculate_draw_grid:
		_set_draw_grid()
		_recalculate_draw_grid = false
	for position: Vector2i in _draw_grid:
		buffer.put_cell(_draw_grid[position], position)


func _set_draw_grid() -> void:
	for x in _rect.size.x:
		for y in _rect.size.y:
			var position := Vector2i(x, y) + offset
			var draw_pos: Vector2i = _rect.position + position - offset
			var cell: TermCell = _grid.get(position, null)
			if cell:
				_draw_grid[draw_pos] = cell


func _update_sizing() -> void:
	_set_draw_grid()
