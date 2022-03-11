# Created by Freeknight
# Date: 2021/12/16
# Desc：色块容器组件
# @category: 辅助UI类
#--------------------------------------------------------------------------------------------------
tool
extends FlexGridContainer
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
# 更新色块记录数据信号
signal grid_item_reordered(index_from, index_to)
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
var draggingColorRect: ColorRect = null
var drag_start_index = -1
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
func _gui_input(event):
	# 跟随鼠标移动色块
	if event is InputEventMouseMotion and draggingColorRect != null:
		var mp = event.position
		for c in get_children():
			c = c as ColorRect
			if c.get_rect().has_point(mp):
				move_child(draggingColorRect, c.get_index())
	
	# 鼠标松开，则更新色块数据
	if (event is InputEventMouseButton and 
			draggingColorRect != null and
			event.get_button_index() == 1 and
			event.is_pressed() == false):
				emit_signal("grid_item_reordered", drag_start_index, draggingColorRect.get_index())
				draggingColorRect = null
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------
