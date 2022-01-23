tool
extends EditorPlugin


const ExchangedResourcePicker = preload(
	"res://addons/imrp/src/scene/ImprovedResourcePicker.tscn"
)


func _enter_tree():
	var editor_tree = get_editor_interface().get_tree()
	editor_tree.connect("node_added", self, "_on_node_added")


func _exit_tree():
	var editor_tree = get_editor_interface().get_tree()
	editor_tree.disconnect("node_added", self, "_on_node_added")


func _on_node_added(node : Node):
	if node.name == 'EditorResourcePicker':
		var menu : PopupMenu = node.find_node("PopupMenu", true, false)
		menu.connect("about_to_show", self, "_on_native_picker_show", [menu])


func _on_native_picker_show(native_picker: PopupMenu):
	var ex_picker = ExchangedResourcePicker.instance()
	
	get_editor_interface().get_editor_viewport().add_child(ex_picker)
	ex_picker.decorate(native_picker)
	ex_picker.popup_centered()
