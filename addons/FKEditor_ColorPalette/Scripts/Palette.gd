# Created by Freeknight
# Date: 2021/12/16
# Desc：一套色盘逻辑对象类
# @category: 辅助类
#--------------------------------------------------------------------------------------------------
tool
extends Reference
class_name Palette
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
var colors: Array = []		# 当前色板信息
var path: String = ""		# 保存的配置完整文件名
var name: String = "Palette"
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
func add_color(p_color : Color, p_index: int = -1) -> void:
	if p_index != -1:
		colors.insert(p_index, p_color)
	else:
		colors.append(p_color)
# ------------------------------------------------------------------------------
func change_color(p_index: int, p_color: Color) -> void:
	colors[p_index] = p_color
# ------------------------------------------------------------------------------
# 更换两个色盘位置
func reorder_color(p_index_from: int, p_index_to: int):
	if p_index_from == p_index_to:
		return
	
	var moving_color = colors[p_index_from]
	if p_index_from < p_index_to:
		colors.remove(p_index_from)
		colors.insert(p_index_to, moving_color)
	
	if p_index_from > p_index_to:
		colors.remove(p_index_from)
		colors.insert(p_index_to, moving_color)
# ------------------------------------------------------------------------------
func remove_color(p_index: int):
	colors.remove(p_index)
# ------------------------------------------------------------------------------
func save():
	if path.ends_with(".gpl") == false:
		push_error("色板文件必须保存以 .gpl 结尾。")
		return

	var file = File.new()
	file.open(path, file.WRITE)
	file.store_line("GIMP Palette")
	
	for c in colors:
		var color_data = [
			str(c.r8), 
			str(c.g8), 
			str(c.b8), 
		]

		var line = PoolStringArray(color_data).join(" ")
		file.store_line(line)

	file.close()
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------
