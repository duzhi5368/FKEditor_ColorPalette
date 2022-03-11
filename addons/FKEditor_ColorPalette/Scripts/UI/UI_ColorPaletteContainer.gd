# Created by Freeknight
# Date: 2021/12/16
# Desc：单独一个色盘组件
# @category: UI面板
#--------------------------------------------------------------------------------------------------
tool
extends PanelContainer
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
signal palette_updated
signal palette_color_selected(palette, color_index)
signal palette_color_deleted(palette, color_index)
signal container_selected(container_object)
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
# 调色板名
onready var name_label = $MarginContainer/VBoxContainer/HBoxContainer/PaletteName
# 色板格子
onready var grid = $MarginContainer/VBoxContainer/PaletteTileContainer/TileContainer

var palette: Palette								# 一个调色板逻辑对象
var undoredo: UndoRedo							# undo/redo管理器
var selected: bool = false setget set_selected 	# 当前本调色板是否被选中状态标识
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
func _ready():
	grid.connect("grid_item_reordered", self, "_grid_item_reordered")
	
	if !palette:
		return

	var cr = ColorTile.new()
	name_label.text = palette.name
	for c in palette.colors:
		var cri = cr.duplicate()
		cri.color = c
		cri.connect("tile_selected", self, "_on_tile_selected")
		cri.connect("tile_deleted", self, "_on_tile_deleted")
		grid.add_child(cri)
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
# 选中某个调色板
func set_selected(value: bool) -> void:
	selected = value
	if selected:
		var sb: StyleBoxFlat = get_stylebox("panel").duplicate()
		sb.bg_color = Color(0.85, 0.83, 0.77)
		add_stylebox_override("panel", sb)
		emit_signal("container_selected", self)
	else:
		var sb: StyleBoxFlat = get_stylebox("panel").duplicate()
		sb.bg_color = Color(0.15, 0.17, 0.23)
		add_stylebox_override("panel", sb)
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
func _gui_input(event):
	if (event is InputEventMouseButton and
			event.get_button_index() == 1 and
			event.is_pressed()):
		self.selected = true
# ------------------------------------------------------------------------------
func _grid_item_reordered(p_index_from: int, p_index_to: int) -> void:
	undoredo.create_action("Reorder Palette %s" % palette.name)
	
	undoredo.add_do_method(palette, "reorder_color", p_index_from, p_index_to)
	undoredo.add_do_method(palette, "save")
	undoredo.add_do_method(self, "emit_signal", "palette_updated")
	undoredo.add_do_method(self, "emit_signal", "palette_color_selected", palette, p_index_to)

	undoredo.add_undo_method(palette, "reorder_color", p_index_to, p_index_from)
	undoredo.add_undo_method(palette, "save")
	undoredo.add_undo_method(self, "emit_signal", "palette_updated")
	undoredo.add_undo_method(self, "emit_signal", "palette_color_selected", palette, p_index_from)
	
	undoredo.commit_action()
# ------------------------------------------------------------------------------
func _on_tile_selected(index):
	emit_signal("palette_color_selected", palette, index)
# ------------------------------------------------------------------------------
func _on_tile_deleted(index):	
	var original_color = palette.colors[index]
	
	undoredo.create_action("Delete Color %s from Palette %s" % [original_color.to_html(), palette.name])

	undoredo.add_do_method(palette, "remove_color", index)
	undoredo.add_do_method(palette, "save")
	undoredo.add_do_method(self, "emit_signal", "palette_updated")

	undoredo.add_undo_method(palette, "add_color", original_color, index)
	undoredo.add_undo_method(palette, "save")
	undoredo.add_undo_method(self, "emit_signal", "palette_updated")
	
	undoredo.commit_action()
### -----------------------------------------------------------------------------------------------
