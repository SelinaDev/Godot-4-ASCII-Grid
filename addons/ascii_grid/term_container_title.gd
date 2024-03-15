class_name TermContainerTitle
extends Resource

## Title configuration to be used by a [TermContainer] node.

enum Alignment { LEFT, CENTER, RIGHT }

## The actual title string to be displayed.
@export var title := ""
## The foreground color the title should be rendered in.
@export var fg_color := Color.WHITE
## The background color the title should be rendered on.
@export var bg_color := Color.BLACK
## Alignment of the title within the top border.
@export var alignment := Alignment.LEFT


