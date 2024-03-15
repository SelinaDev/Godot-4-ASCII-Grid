class_name TermSingleCell
extends TermElement

## A node to draw a single cell onto an ASCII Terminal
##
## This node allows to draw a single cell at a specified position.
## This position is a local position, i.e., relative to the parent on the screen.

## Local position of the cell, relative to the parent cell.
@export var position: Vector2i:
	set(value):
		position = value
		_redraw_required = true
## Character to be drawn in the cell.
@export var character: String = "":
	set(value):
		character = value
		_cell.character = character
		_redraw_required = true
## Foreground color the cell is drawn in.
@export var fg_color: Color = Color.WHITE:
	set(value):
		fg_color = value
		_cell.fg_color = fg_color
		_redraw_required = true
## Background color the cell is drawn on.
@export var bg_color: Color = Color.BLACK:
	set(value):
		bg_color = value
		_cell.bg_color = bg_color
		_redraw_required = true

var _cell := TermCell.new()


func _blit_self_under(buffer: TermBuffer) -> void:
	var draw_pos: Vector2i = position + _rect.position
	buffer.put_cell(_cell, draw_pos)
