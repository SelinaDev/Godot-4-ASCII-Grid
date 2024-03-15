class_name TermBuffer
extends RefCounted

## A buffer for the terminal
##
## This is a buffer containing [TermCell]s corresponding to positions in the terminal's grid.

var _grid := {}
var _size: Vector2i
var _draw_region: Rect2i


func _init(buffer_size: Vector2i) -> void:
	_size = buffer_size
	_draw_region = Rect2i(Vector2i.ZERO, _size)
	_grid = {}

## Specifies the active draw region of the buffer. Calls to [method TermBuffer.put_cell] will be filtered by this region, so that trying to set a cell outside the draw region will have no effect.
## This is mainly used by [TermElement] nodes to restrict drawing to their own area.
func set_draw_region(draw_region: Rect2i) -> void:
	_draw_region = draw_region

## Returns the buffer's current draw region.
func get_draw_region() -> Rect2i:
	return _draw_region

## Resets the draw region to include the whole size of the buffer. See [method TermBuffer.set_draw_region].
func reset_draw_region() -> void:
	_draw_region = Rect2i(Vector2i.ZERO, _size)

## Sets an individual cell in the buffer. This method is filtered by the current draw region of the buffer (see [method TermBuffer.set_draw_region]. Placing a cell outside the current draw region has no effect.
func put_cell(cell: TermCell, at: Vector2i) -> void:
	if _draw_region.has_point(at):
		_grid[at] = cell


## Returns the cell as the specified position from the buffer. Returns [code]null[/code] if no cell is present at that position.
func get_cell(at: Vector2i) -> TermCell:
	return _grid.get(at, null)
