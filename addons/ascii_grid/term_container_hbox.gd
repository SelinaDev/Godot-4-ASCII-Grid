class_name TermContainerHBox
extends TermContainer

## A ASCII terminal container arranging its children horizontally.
##
## This container works analogous to [HBoxContainer], and will try to distribute it's children horizontally.
## All children will be stretched to the height available to this container.
## Any children with a set fixed width (i.e., [code]fixed_size.x[/code] greater than [code]0[/code]) will be set to that width.
## The remaining width will be evenly distributed between all children without fixed width (i.e., [code]fixed_size.x[/code] set to [code]0[/code]).

func _arrange_children() -> void:
	var total_content_rect: Rect2i = get_content_rect()
	var available_width: int = total_content_rect.size.x - _children.reduce(func(accum: int, child: TermElement) -> int: return accum + child.fixed_size.x, 0)
	var children_to_distribute: int = _children.filter(func(child: TermElement) -> bool: return child.fixed_size.x == 0).size()
	var width_per_child: int = available_width / children_to_distribute if children_to_distribute > 0 else 0
	var remainder: int = available_width % children_to_distribute if children_to_distribute > 0 else 0 # Add this to the first child
	
	var running_pos: int = 0
	for child: TermElement in _children:
		var child_pos: Vector2i = total_content_rect.position
		child_pos.x += running_pos
		var child_size := Vector2i.ZERO
		child_size.y = total_content_rect.size.y
		var child_width: int = child.get_fixed_width()
		if child_width == 0:
			child_width = width_per_child + remainder
			remainder = 0
		child_size.x = child_width
		child.set_rect(
			Rect2i(
				child_pos,
				child_size
			)
		)
		running_pos += child_width
