class_name TermRect
extends ColorRect

## Control node for rendering an ASCII terminal.
##
## This node is responsible for the visual output of the ASCII terminal rendering system.

const _SHADER = preload("res://addons/ascii_grid/term_shader.gdshader")

@export_category("Font configuration")
## The source font file. This requires an image file with characters according to Code Page 437.
@export var font: Texture

## The size of an individual tile. Needs to be set according to the source font file.
@export var tile_size: Vector2i = Vector2i(8, 16):
	set(value):
		tile_size = value
		if not is_inside_tree():
			await ready
		var shader_tile_size := Vector2(1.0 / tile_size.x, 1.0 / tile_size.y)
		(material as ShaderMaterial).set_shader_parameter("tile_size", shader_tile_size)

## Number of characters per line in the font image file.
@export var characters_per_line := 16:
	set(value):
		characters_per_line = value
		if not is_inside_tree():
			await ready
		(material as ShaderMaterial).set_shader_parameter("chars_per_line", characters_per_line)

## Root node of the rendered terminal nodes.
@export var term_root: TermElement

## The color to draw for empty terminal cells.
@export_color_no_alpha var clear_color: Color = Color.BLACK

## If a [property TermRect.term_root] is configured, the [TermRect] will automatically redraw it whenever its visual representation changes.
@export var automatic_redraw: bool = true

var _grid_size: Vector2i
var _fg_image: Image
var _bg_image: Image
var _chars_image: Image
var _resize_required: bool = true

func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = _SHADER
	material.set_shader_parameter("glyphs", font)
	material.set_shader_parameter("chars_per_line", characters_per_line)
	anchors_preset = PRESET_FULL_RECT
	item_rect_changed.connect(_set_resize_required)
	_set_resize_required()


func _process(_delta: float) -> void:
	if _resize_required:
		_resize()
		_resize_required = false
	if automatic_redraw and term_root and term_root.is_redraw_required():
		render()


## Obtains a new, empty buffer that has the same size as this [TermRect]'s grid.
func create_buffer() -> TermBuffer:
	return TermBuffer.new(_grid_size)

## Renders a [TermBuffer] to the [TermRect]. Uses [param empty_color] for positions not specified in the [param buffer].
## This method may be called directly, by supplying a buffer (see [method TermRect.create_buffer]). Alternatively, use [method TermRect.render].
func render_buffer(buffer: TermBuffer, clear_color: Color = clear_color) -> void:
	var empty_cell := TermCell.new(" ", clear_color, clear_color)
	for y: int in _grid_size.y:
		for x: int in _grid_size.x:
			var grid_pos := Vector2i(x, y)
			var cell: TermCell = buffer._grid.get(grid_pos, null)
			if not cell:
				cell = empty_cell
			var char_value: float = cell.get_character_id() / 256.0
			_chars_image.set_pixelv(grid_pos, Color(char_value, 0.0, 0.0, 0.0))
			_fg_image.set_pixelv(grid_pos, cell.fg_color)
			_bg_image.set_pixelv(grid_pos, cell.bg_color)
	(material as ShaderMaterial).set_shader_parameter("character_grid", ImageTexture.create_from_image(_chars_image))
	(material as ShaderMaterial).set_shader_parameter("fg_color", ImageTexture.create_from_image(_fg_image))
	(material as ShaderMaterial).set_shader_parameter("bg_color", ImageTexture.create_from_image(_bg_image))

## Renders the tree of [TermElements] at [property TermRect.term_root].
## [TermElement] nodes in the configured tree will automatically draw themselves to an internal buffer, which will then be rendered to the terminal.
## Will create an error if [property TermRect.term_root] is [code]null[/code] (i.e., unconfigured).
func render() -> void:
	if not term_root:
		push_error("No terminal root node configured. render() can only be called whith a TermElement as root node.")
		return
	var buffer: TermBuffer = create_buffer()
	term_root.blit_to_buffer(buffer)
	render_buffer(buffer)


func _set_resize_required() -> void:
	_resize_required = true


func _resize() -> void:
	var parent_size: Vector2i = get_parent().size
	_grid_size = Vector2i(parent_size) / tile_size
	set_deferred("size", _grid_size * tile_size)
	(material as ShaderMaterial).set_shader_parameter("grid_size", _grid_size)
	_fg_image = Image.create(_grid_size.x, _grid_size.y, false, Image.FORMAT_RGBA8)
	_bg_image = Image.create(_grid_size.x, _grid_size.y, false, Image.FORMAT_RGBA8)
	_chars_image = Image.create(_grid_size.x, _grid_size.y, false, Image.FORMAT_RGBA8)
	if term_root:
		term_root.set_rect(Rect2i(Vector2i.ZERO, _grid_size))
		term_root.update_sizing()
