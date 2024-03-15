class_name TermLabel
extends TermElement

## A string of text to display in a ASCII terminal

enum TextWrap {
	NONE,
	ARBITRARY,
	WORD_BORDER
}

## The text to be displayed. Can only contain characters from codepage 437 (any other characters will be rendered as a blank space).
@export_multiline var text: String = "":
	set(value):
		text = value
		_set_text_grid()
		_redraw_required = true
## How to wrap text if the label is longer than the parent container.
## [br][br]None: Don't wrap text. Any text that doesn't fit will be clipped.
## [br]Arbitrary: Fills the available with and then continues in the next line, regardless of word borders.
## [br]Word Border: Will perform line breaks only between words.
@export var text_wrap := TextWrap.WORD_BORDER:
	set(value):
		text_wrap = value
		_set_text_grid()
		_redraw_required = true
## Color to render the text in.
@export var fg_color := Color.WHITE:
	set(value):
		fg_color = value
		_set_text_grid()
		_redraw_required = true
## Background color to render the text on.
@export var bg_color := Color.BLACK:
	set(value):
		bg_color = value
		_set_text_grid()
		_redraw_required = true

var _text_grid: Dictionary


func _ready() -> void:
	super()
	_set_text_grid()


func get_fixed_width() -> int:
	return max(fixed_size.x, text.length())


func get_fixed_height() -> int:
	match text_wrap:
		TextWrap.ARBITRARY:
			return _determine_text_height_arbitrary()
		TextWrap.WORD_BORDER:
			return _determine_text_height_wordborder()
		_:
			return _determine_text_height_none()


func _determine_text_height_none() -> int:
	return 1


func _determine_text_height_arbitrary() -> int:
	var text_height: int = text.length() / _rect.size.x
	return text_height


func _determine_text_height_wordborder() -> int:
	var lines: PackedStringArray = text.split("\n")
	var text_height := 0
	var line_lenth := 0
	var max_line_length := _rect.size.x
	for line: String in lines:
		text_height += 1
		for text_element: String in line.split(" "):
			var element_length := text_element.length()
			if line_lenth + 1 + element_length > max_line_length:
				text_height += 1
				line_lenth = element_length
			else:
				line_lenth += 1 + element_length
		line_lenth = 0
	return text_height


func _blit_self_under(buffer: TermBuffer) -> void:
	for position: Vector2i in _text_grid:
		buffer.put_cell(_text_grid[position], position)


func _set_text_grid() -> void:
	match text_wrap:
		TextWrap.ARBITRARY:
			_set_text_grid_arbitrary()
		TextWrap.WORD_BORDER:
			_set_text_grid_word_border()
		_:
			_set_text_grid_no_text_wrap()


func _set_text_grid_no_text_wrap() -> void:
	_text_grid = {}
	for x: int in min(_rect.size.x, text.length()):
		var draw_pos: Vector2i = _rect.position + Vector2i.RIGHT * x
		_text_grid[draw_pos] = TermCell.new(text[x], fg_color, bg_color)


func _set_text_grid_arbitrary() -> void:
	_text_grid = {}
	var line_length := _rect.size.x
	for i: int in text.length():
		var x := i % line_length
		var y := i / line_length
		var draw_pos: Vector2i = _rect.position + Vector2i(x, y)
		_text_grid[draw_pos] = TermCell.new(text[i], fg_color, bg_color)


func _set_text_grid_word_border() -> void:
	_text_grid = {}
	var line_length := _rect.size.x
	var y := 0
	var x := 0
	for line: String in text.split("\n"):
		for text_element: String in line.split(" "):
			if x + 1 + text_element.length() > line_length:
				y += 1
				x = 0
			var start_pos: Vector2i = _rect.position + Vector2i(x, y)
			if x != 0:
				if not _rect.has_point(start_pos): continue
				_text_grid[start_pos] = TermCell.new(" ", fg_color, bg_color)
				x += 1
				start_pos += Vector2i.RIGHT
			for i: int in text_element.length():
				var draw_pos: Vector2i = start_pos + Vector2i.RIGHT * i
				_text_grid[draw_pos] = TermCell.new(text_element[i], fg_color, bg_color)
			x += text_element.length()
		y += 1
		x = 0


func _update_sizing() -> void:
	_set_text_grid()
