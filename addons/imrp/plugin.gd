@tool
extends EditorPlugin


const ImprovedResourcePicker = preload(
	"res://addons/imrp/src/scene/ImprovedResourcePicker.tscn"
)


func _enter_tree():
	var editor_tree = get_editor_interface().get_base_control().get_tree()
	editor_tree.node_added.connect(_on_node_added)


func _exit_tree():
	var editor_tree = get_editor_interface().get_base_control().get_tree()
	editor_tree.node_added.disconnect(_on_node_added)


func _on_node_added(node : Node):
	if node is PopupMenu and node.get_parent() is EditorResourcePicker:
		node.about_to_popup.connect(_on_native_picker_show.bind(node))


func _on_native_picker_show(native_picker: PopupMenu):
	var ex_picker = ImprovedResourcePicker.instantiate()
	get_editor_interface().get_base_control().add_child(ex_picker)
	ex_picker.decorate(native_picker)
	ex_picker.popup_centered(Vector2(400, 600) * get_editor_interface().get_editor_scale())
