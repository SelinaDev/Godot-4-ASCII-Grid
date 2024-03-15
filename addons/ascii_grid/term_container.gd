class_name TermContainer
extends TermElement

## Base class for containing other [TermElement]s.
##
## This is the base container class of the ASCII terminal system.
## When determining sizes, this node will simply stretch all it's children's size rects to it's own size.

## If [property border] is set, the container will draw a border around its outer edge.
## Styling of this border can be determined within the provided [TermContainerBorderConfig].
@export var border: TermContainerBorderConfig:
	set(value):
		border = value
		_redraw_required = true
		if border:
			border.changed.connect(_set_dirty)
## If both [property border] and [property title] are set, a title will be drawn at the top edge of the border.
## The title string itself, as well as its styling can be determined with the provided [TermContainerTitle].
@export var title: TermContainerTitle:
	set(value):
		title = value
		_redraw_required = true
		if title:
			title.changed.connect(_set_dirty)


## The rectangle available for drawing content in this container.
## This region does not include the [property border], if set.
func get_content_rect() -> Rect2i:
	if border:
		return _rect.grow(-1)
	return _rect

## Container version of [method TermElement.update_sizing]. Internally calls [method TermContainer._arrange_children].
func update_sizing() -> void:
	_arrange_children()
	super()

## Arranges child nodes accoriding to container rules.
## Custom containers inheriting [TermContainer] should override this method.
func _arrange_children() -> void:
	var total_content_rect: Rect2i = get_content_rect()
	for child: TermElement in _children:
		child.set_rect(total_content_rect)


func _blit_self_over(buffer: TermBuffer) -> void:
	if border:
		_draw_border(buffer)
		if title:
			_draw_title(buffer)


func _draw_border(buffer: TermBuffer) -> void:
	if not border: return
	
	var cell_top := TermCell.new(border.top_border, border.fg_color, border.bg_color)
	var cell_bottom := TermCell.new(border.bottom_border, border.fg_color, border.bg_color)
	for x in range(_rect.position.x, _rect.end.x):
		buffer.put_cell(cell_top, Vector2i(x, _rect.position.y))
		buffer.put_cell(cell_bottom, Vector2i(x, _rect.end.y - 1))
	
	var cell_left := TermCell.new(border.left_border, border.fg_color, border.bg_color)
	var cell_right := TermCell.new(border.right_border, border.fg_color, border.bg_color)
	for y in range(_rect.position.y, _rect.end.y):
		buffer.put_cell(cell_left, Vector2i(_rect.position.x, y))
		buffer.put_cell(cell_left, Vector2i(_rect.end.x - 1, y))
	
	var corners: Array[Vector2i] = [
		_rect.position,
		_rect.position + Vector2i(_rect.size.x - 1, 0),
		_rect.position + Vector2i(0, _rect.size.y - 1),
		_rect.end - Vector2i.ONE
	]
	var corner_chars: Array[String] = [
		border.top_left_corner,
		border.top_right_corner,
		border.bottom_left_corner,
		border.bottom_right_corner
	]
	for i in 4:
		buffer.put_cell(TermCell.new(corner_chars[i], border.fg_color, border.bg_color), corners[i])

func _draw_title(buffer: TermBuffer) -> void:
	if not title: return

	var title_start_pos := Vector2i.ZERO
	title_start_pos.y = _rect.position.y
	match title.alignment:
		TermContainerTitle.Alignment.LEFT:
			title_start_pos.x = _rect.position.x + 1
		TermContainerTitle.Alignment.CENTER:
			title_start_pos.x = _rect.position.x + _rect.size.x / 2 - title.title.length() / 2
		TermContainerTitle.Alignment.RIGHT:
			title_start_pos.x = _rect.end.x - 1 - title.length()
	for i: int in title.title.length():
		var draw_pos: Vector2i = title_start_pos + Vector2i.RIGHT * i
		buffer.put_cell(TermCell.new(title.title[i], title.fg_color, title.bg_color), draw_pos)
