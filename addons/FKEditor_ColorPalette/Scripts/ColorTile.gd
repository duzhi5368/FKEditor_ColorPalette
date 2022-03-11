# Created by Freeknight
# Date: 2021/12/16
# Desc：单一色块组件
# @category: 辅助UI类
#--------------------------------------------------------------------------------------------------
tool
extends ColorRect
class_name ColorTile
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
signal tile_deleted(index)
signal tile_selected(index)
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
onready var parent = get_parent()
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
func _ready():
	rect_min_size = Vector2(30,30)	# 大小限制
	mouse_filter = MOUSE_FILTER_PASS	# 允许消息穿透，以便自行处理
# ------------------------------------------------------------------------------
func _gui_input(event):
	if event is InputEventMouseButton:
		# 左键点选消息
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			parent.draggingColorRect = self
			parent.drag_start_index = get_index()
			emit_signal("tile_selected", get_index())
			accept_event()
			return
		# 右键删除消息
		if event.button_index == BUTTON_RIGHT and event.is_pressed():
			emit_signal("tile_deleted", get_index())
			accept_event()
			return
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------
