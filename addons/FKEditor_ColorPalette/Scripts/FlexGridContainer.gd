# Created by Freeknight
# Date: 2021/12/16
# Desc：色块容器基类
# @category: 辅助UI类
#--------------------------------------------------------------------------------------------------
tool
extends Container

# 这里为编辑器中展示指定了icon
class_name FlexGridContainer, "res://addons/FKEditor_ColorPalette/Assets/Pics/FlexGridContainerIcon.png"
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
var columns: int = 1 setget set_columns
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
func set_columns(p_columns: int):
	columns = p_columns
	minimum_size_changed()
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
func _notification(p_what):
	match p_what:
		NOTIFICATION_SORT_CHILDREN:		
			var col_minw: Dictionary 	# 每列控件的最小宽度（索引为列数）
			var row_minh: Dictionary 	# 每行控件的最小高度（索引为行数）
			var col_expanded: Array 	# 设置了 SIZE_EXPAND 标识的列
			var row_expanded: Array 	# 设置了 SIZE_EXPAND 标识的行

			var hsep = get_constant("hseparation", "GridContainer")
			var vsep = get_constant("vseparation", "GridContainer")
			var min_columns = 1
			if get_child_count() > 0:
				min_columns = int(floor(rect_size.x / (get_child(0).get_combined_minimum_size().x + hsep)))
			self.columns = min_columns
			
			var max_col = min(get_child_count(), columns)
			var max_row = ceil(float(get_child_count()) / float(columns))

			# 计算单行/列数据
			var valid_controls_index = 0
			for i in range(get_child_count()):
				var c: Control = get_child(i)
				if !c or !c.is_visible_in_tree():
					continue

				var row = valid_controls_index / columns
				var col = valid_controls_index % columns
				valid_controls_index += 1

				var ms: Vector2 = c.get_combined_minimum_size()
				if col_minw.has(col):
					col_minw[col] = max(col_minw[col], ms.x)
				else:
					col_minw[col] = ms.x
				if row_minh.has(row):
					row_minh[row] = max(row_minh[row], ms.y)
				else:
					row_minh[row] = ms.y

				if c.get_h_size_flags() & SIZE_EXPAND:
					col_expanded.push_front(col)					
				if c.get_v_size_flags() & SIZE_EXPAND:
					row_expanded.push_front(row)

			# 计算当所有空列都展开时的情况
			for i in range(valid_controls_index, columns):
				col_expanded.push_front(i)

			# 计算展开行/列后的剩余空间
			var remaining_space: Vector2 = get_size()			
			for e in col_minw.keys():
				if !col_expanded.has(e):
					remaining_space.x -= col_minw.get(e)
			for e in row_minh.keys():
				if !row_expanded.has(e):
					remaining_space.y -= row_minh.get(e)

			remaining_space.y -= vsep * max(max_row - 1, 0)
			remaining_space.x -= hsep * max(max_col - 1, 0)

			# 计算宽度
			var can_fit = false
			while !can_fit && col_expanded.size() > 0:
				# 计算剩余空间是否足够展开
				can_fit = true
				var max_index = col_expanded.front()
				
				for e in col_expanded:
					if col_minw.has(e):
						if col_minw[e] > col_minw[max_index]:
							max_index = e
						if can_fit && (remaining_space.x / col_expanded.size()) < col_minw[e]:
							can_fit = false

				# 剩余空间不足
				if (!can_fit):
					col_expanded.erase(max_index)
					remaining_space.x -= col_minw[max_index]


			# 计算高度
			can_fit = false
			while !can_fit && row_expanded.size() > 0:
				can_fit = true
				var max_index = row_expanded.front()
				
				for e in row_expanded:
					if row_minh[e] > row_minh[max_index]:
						max_index = e
					if can_fit && (remaining_space.y / row_expanded.size()) < row_minh[e]:
						can_fit = false

				if (!can_fit):
					row_expanded.erase(max_index)
					remaining_space.y -= row_minh[max_index]


			# 最终，处理全部节点
			var col_expand = remaining_space.x / col_expanded.size() if col_expanded.size() > 0 else 0
			var row_expand = remaining_space.y / row_expanded.size() if row_expanded.size() > 0 else 0
			var col_ofs = 0
			var row_ofs = 0

			valid_controls_index = 0
			for i in range(get_child_count()):
				var c: Control = get_child(i)
				if (!c || !c.is_visible_in_tree()):
					continue
				var row = valid_controls_index / columns
				var col = valid_controls_index % columns
				valid_controls_index += 1

				if (col == 0):
					col_ofs = 0
					if (row > 0):
						row_ofs += (row_expand if row_expanded.has(row - 1) else row_minh[row - 1]) + vsep

				var p = Vector2(col_ofs, row_ofs)
				var s = Vector2(col_expand if col_expanded.has(col) else col_minw[col], row_expand if row_expanded.has(row) else row_minh[row])
				fit_child_in_rect(c, Rect2(p, s))
				col_ofs += s.x + hsep
		
		# 处理样式大小更变消息
		NOTIFICATION_THEME_CHANGED:
			minimum_size_changed()
# ------------------------------------------------------------------------------
func _get_minimum_size():
	# 这里只处理高度即可，宽度不管，自动处理
	var row_minh: Dictionary
	var vsep = get_constant("vseparation", "GridContainer")
	var max_row = 0
	var valid_controls_index = 0
	
	for i in range(get_child_count()):
		var c: Control = get_child(i)
		if !c or !c.is_visible():
			continue
		var row = valid_controls_index / columns
		valid_controls_index += 1
		var ms = c.get_combined_minimum_size()

		if row_minh.has(row):
			row_minh[row] = max(row_minh[row], ms.y)
		else:
			row_minh[row] = ms.y
		max_row = max(row, max_row)

	var ms: Vector2
	for e in row_minh.keys():
		ms.y += row_minh.get(e)
	ms.y += vsep * max_row

	return ms
### -----------------------------------------------------------------------------------------------







