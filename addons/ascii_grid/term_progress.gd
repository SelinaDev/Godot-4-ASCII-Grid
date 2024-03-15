class_name TermProgress
extends TermElement

## A node to draw a progress bar in an ASCII terminal.

## The maximum value of the progress bar.
@export var max_value: int:
	set(value):
		max_value = value
		_set_bar()
		_redraw_required = true
## The current value of the progress bar
@export var value: int:
	set(new_value):
		value = new_value
		_set_bar()
		_redraw_required = true

## The color the filled segments of the bar are drawn in.
@export var fg_color_filled := Color.WHITE:
	set(value):
		fg_color_filled = value
		_set_bar()
		_redraw_required = true
## The color the empty segments of the bar are drawn in. Note: This affects the [i]foreground[/i] of the [property TermProgress.empty_character]. If the [property TermProgress.empty_character] does not print anything (e.g., it's a " "), this will have no effect.
@export var fg_color_empty:= Color.WHITE:
	set(value):
		fg_color_empty = value
		_set_bar()
		_redraw_required = true
## The background color the bar is drawn on.
@export var bg_color := Color.BLACK:
	set(value):
		bg_color = value
		_set_bar()
		_redraw_required = true
## The character to represent a filled segment of the progress bar.
@export var full_character := "█":
	set(value):
		full_character = value
		_set_bar()
		_redraw_required = true
## The character used to represent an empty segment of the 
@export var empty_character := "░":
	set(value):
		empty_character = value
		_set_bar()
		_redraw_required = true


var _bar: Dictionary


func _ready() -> void:
	super()
	_set_bar()


func _blit_self_under(buffer: TermBuffer) -> void:
	for position: Vector2i in _bar:
		buffer.put_cell(_bar[position], position)


func _set_bar() -> void:
	_bar = {}
	var width := _rect.size.x
	if max_value <= 0:
		return
	var filled := roundi(float(width) * (float(value) / float(max_value)))
	var full_cell := TermCell.new(full_character, fg_color_filled, bg_color)
	var empty_cell := TermCell.new(empty_character, fg_color_empty, bg_color)
	for x: int in width:
		var draw_pos: Vector2i = _rect.position + Vector2i.RIGHT * x
		var used_cell: TermCell = full_cell if x <= filled else empty_cell
		_bar[draw_pos] = used_cell


func get_fixed_height() -> int:
	return 1


func _update_sizing() -> void:
	_set_bar()
