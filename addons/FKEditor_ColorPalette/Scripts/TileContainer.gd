# Created by Freeknight
# Date: 2021/12/16
# Desc：
# @category: 辅助UI类
#--------------------------------------------------------------------------------------------------
tool
extends FlexGridContainer
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
signal grid_item_reordered(index_from, index_to)
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
var dragging: ColorRect = null
var drag_start_index = -1
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
func _gui_input(event):
	if event is InputEventMouseMotion and dragging != null:
#		Move the color rect as the user drags it for a live preview
		var mp = event.position
		for c in get_children():
			c = c as ColorRect
			if c.get_rect().has_point(mp):
				move_child(dragging, c.get_index())
		
	if (event is InputEventMouseButton and 
			dragging != null and
			event.get_button_index() == 1 and
			event.is_pressed() == false):
				emit_signal("grid_item_reordered", 
						drag_start_index, 
						dragging.get_index())
								
				dragging = null
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------
