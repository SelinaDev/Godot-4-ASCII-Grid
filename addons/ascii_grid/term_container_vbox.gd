class_name TermContainerVBox
extends TermContainer

## A ASCII terminal container arranging its children vertically.
##
## This container works analogous to [VBoxContainer], and will try to distribute it's children vertically.
## All children will be stretched to the width available to this container.
## Any children with a set fixed height (i.e., [code]fixed_size.y[/code] greater than [code]0[/code]) will be set to that height.
## The remaining height will be evenly distributed between all children without fixed height (i.e., [code]fixed_size.y[/code] set to [code]0[/code]).


func _arrange_children() -> void:
	var total_content_rect: Rect2i = get_content_rect()
	var available_height: int = total_content_rect.size.y - _children.reduce(func(accum: int, child: TermElement) -> int: return accum + child.fixed_size.y, 0)
	var children_to_distribute: int = _children.filter(func(child: TermElement) -> bool: return child.fixed_size.y == 0).size()
	var height_per_child: int = available_height / children_to_distribute if children_to_distribute > 0 else 0
	var remainder: int = available_height % children_to_distribute if children_to_distribute > 0 else 0 # Add this to the first child
	
	var running_pos: int = 0
	for child: TermElement in _children:
		var child_pos: Vector2i = total_content_rect.position
		child_pos.y += running_pos
		var child_size := Vector2i.ZERO
		child_size.x = total_content_rect.size.x
		var child_height: int = child.get_fixed_height()
		if child_height == 0:
			child_height = height_per_child + remainder
			remainder = 0
		child_size.y = child_height
		child.set_rect(
			Rect2i(
				child_pos,
				child_size
			)
		)
		running_pos += child_height
