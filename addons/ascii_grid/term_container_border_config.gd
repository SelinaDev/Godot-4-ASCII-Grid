class_name TermContainerBorderConfig
extends Resource

## Border configuration resource to be used by a [TermContainer].

@export_category("Border Characters")
@export var top_border: String = "─"
@export var bottom_border: String = "─"
@export var left_border: String = "│"
@export var right_border: String = "│"
@export var top_left_corner: String = "┌"
@export var top_right_corner: String = "┐"
@export var bottom_left_corner: String = "└"
@export var bottom_right_corner: String = "┘"

@export_category("Border Colors")
@export var fg_color: Color = Color.WHITE ## Foreground color of the corder characters.
@export var bg_color: Color = Color.BLACK ## Background color of the border characters.


