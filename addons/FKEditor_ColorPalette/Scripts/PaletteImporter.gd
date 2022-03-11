# Created by Freeknight
# Date: 2021/12/16
# Desc：负责色盘文件解析加载
# @category: 辅助类
#--------------------------------------------------------------------------------------------------
tool
extends Reference
class_name PaletteImporter
### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------
#--- enums ----------------------------------------------------------------------------------------
#--- constants ------------------------------------------------------------------------------------
#--- public variables - order: export > normal var > onready --------------------------------------
#--- private variables - order: export > normal var > onready -------------------------------------
### -----------------------------------------------------------------------------------------------

### Built in Engine Methods -----------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------

### Public Methods --------------------------------------------------------------------------------
# 加载指定的 gpl 文件
static func import_gpl(path : String) -> Palette:
	var color_line_regex = RegEx.new()
	var result : Palette = null
	var err = color_line_regex.compile("(?<red>[0-9]{1,3})[ \t]+(?<green>[0-9]{1,3})[ \t]+(?<blue>[0-9]{1,3})")
	if err:
		printerr("编译调色板格式正则表达失败。")
		return result

	var file = File.new()
	if !file.file_exists(path):
		push_error("文件 \"%s\" 不存在。" % path)
		return result
	
	file.open(path, File.READ)
	var text = file.get_as_text()
	var lines = text.split('\n')
	var line_number := 0
	for line in lines:
		line = line.lstrip(" ")
		if line_number == 0:			# 文件有效性检查
			if line != "GIMP Palette":
				push_error("文件 \"%s\" 不是一个有效的 GIMP 调色板文件。" % path)
				break
			else:
				result = Palette.new()
				result.path = path
				var name_start = path.find_last('/') + 1
				var name_end = path.find_last('.')
				if name_end > name_start:
					result.name = path.substr(name_start, name_end - name_start)
		elif line.begins_with('#'):	# 文件注释处理，兼容老版本
			pass
		elif not line.empty():
			var matches = color_line_regex.search(line)
			if matches:
				var red: float = matches.get_string("red").to_float() / 255.0
				var green: float = matches.get_string("green").to_float() / 255.0
				var blue: float = matches.get_string("blue").to_float() / 255.0
				var color = Color(red, green, blue)
				result.add_color(color)
			else:
				push_error("解析调色办文件失败：第 %s 行 - %s" % [line_number + 1, line])
		line_number += 1
	file.close()

	return result
# ------------------------------------------------------------------------------
# 查找路径下的全部 gpl 文件
static func get_gpl_files(path) -> Array:
	var files = []

	var dir = Directory.new()
	if dir.open(path) != OK:
		printerr("尝试访问调色板文件时出现异常错误。")
		return files
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir() and file_name.ends_with(".gpl"):
			files.append(path + file_name)
		file_name = dir.get_next()

	return files
### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------
### -----------------------------------------------------------------------------------------------
