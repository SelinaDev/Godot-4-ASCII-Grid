class_name TermElement
extends Node

## The base terminal element.
##
## This is the base class for ASCII terminal elements.
## The terminal system is intended to work with a tree of nodes derived from this class.
## This base class provides the basic functionality for recursively drawing [TermElement] nodes.
## It can be extended by overriding [method TermElement._blit_self_under] and [method TermElement._blit_self_over].

signal visual_representation_changed

## The fixed size of the element. This property is used by the [TermContainer] variants to determine sizing.
@export var fixed_size := Vector2i.ZERO

var _children: Array[TermElement] = []
var _rect: Rect2i
var _redraw_required := true:
	set(value):
		if not _redraw_required and value:
			_redraw_required = true
			visual_representation_changed.emit()
		else:
			_redraw_required = value


func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	for child: Node in get_children():
		_on_child_entered_tree(child)


func _on_child_entered_tree(child: Node) -> void:
	if child is TermElement:
		_children.append(child)
		child.visual_representation_changed.connect(_on_child_visual_representation_changed)
		update_sizing()


func _on_child_exiting_tree(child:Node) -> void:
	_children.erase(child)
	update_sizing()

## This method initiates an update of the sizing of this node and it's children (recursively).
func update_sizing() -> void:
	_redraw_required = true
	for child: TermElement in _children:
		child.update_sizing()
	_update_sizing()


func _update_sizing() -> void:
	pass


## Blits the node and it's children to the provided [TermBuffer].
## This works by first calling [method TermElement._blit_self_under], then recursively calling this function on all [TermElement] children, then calling [method TermElement._blit_self_over].
func blit_to_buffer(buffer: TermBuffer) -> void:
	buffer.set_draw_region(_rect)
	_blit_self_under(buffer)
	for child: TermElement in _children:
		child.blit_to_buffer(buffer)
	_blit_self_over(buffer)
	buffer.reset_draw_region()
	_redraw_required = false

## Draws the [TermElement]'s contents to the buffer.
## Contents are drawn before any children are drawn, and can be overdrawn by them.
## Does nothing on the base [TermElement], and is intended to be overridden by inheriting classes.
## This method is intended as a general draw function for [TermElement]
func _blit_self_under(_buffer: TermBuffer) -> void:
	pass

## Draws the [TermElement]'s contents to the buffer.
## Contents are drawn after all children are done drawing, and can overdraw previously drawn cells.
## Does nothing on the base [TermElement], and is indented to be overriden by inheriting classes.
## This method is intended for decorations, e.g., borders, that are drawn over the content and children.
func _blit_self_over(_buffer: TermBuffer) -> void:
	pass

## This returns the width component ([code]x[/code]) of [member TermElement.fixed_size].
## May be overriden in special cases where a required width needs to be calculated dynamically, e.g., texts spanning multiple lines.
func get_fixed_width() -> int:
	return fixed_size.x

## This returns the height component ([code]y[/code]) of [member TermElement.fixed_size].
## May be overriden in special cases where a required height needs to be calculated dynamically, e.g., texts spanning multiple lines.
func get_fixed_height() -> int:
	return fixed_size.y

## Sets the rectangle in which the [TermElement] is allowed to draw to a [TermBuffer] (in global grid coordinates).
func set_rect(rect: Rect2i) -> void:
	_rect = rect

## Returns the rectangle in which the [TermElement] is allowed to draw to a [TermBuffer] (in global grid coordinates).
func get_rect() -> Rect2i:
	return _rect

## Returns an array of all [TermElement] children of this node.
func get_term_children() -> Array[TermElement]:
	return _children.duplicate()


func _on_child_visual_representation_changed() -> void:
	_redraw_required = true

## Returns whether the visual representation of this node or any of its children has changed since it was last rendered.
func is_redraw_required() -> bool:
	return _redraw_required


func _set_dirty() -> void:
	_redraw_required = true
