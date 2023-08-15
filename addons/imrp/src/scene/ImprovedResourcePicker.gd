@tool
extends ConfirmationDialog

@onready var tree : Tree = $VBoxContainer/Tree
@onready var line_edit = $VBoxContainer/LineEdit

var native : PopupMenu
var schemas = []


func _ready():
	line_edit.clear_button_enabled = true
	line_edit.focus_neighbor_bottom = line_edit.get_path()
	line_edit.focus_neighbor_top = line_edit.get_path()
	line_edit.gui_input.connect(func(event):
		if event.has_meta("___improved_resource_picker_line_edit_handled___"): return
		var k = event as InputEventKey
		if k:
			match k.keycode:
				KEY_UP, KEY_DOWN, KEY_PAGEDOWN, KEY_PAGEUP:
					tree.grab_focus()
					line_edit.accept_event()
					var e = event.duplicate()
					e.set_meta("___improved_resource_picker_line_edit_handled___", true)
					Input.parse_input_event(e)
	)
	
	tree.gui_input.connect(func(_event): 
		line_edit.grab_focus()
	)
	
	register_text_enter(line_edit)


func decorate(native: PopupMenu):
	native.call_deferred("hide")
	
	self.native = native
	self.schemas = []
	
	var rest_options_idx = -1
	
	for idx in range(native.get_item_count()):
		if native.is_item_separator(idx):
			rest_options_idx = idx + 1
			break
			
		self.schemas.append(
			{
				"id": native.get_item_id(idx),
				"text": native.get_item_text(idx),
				"icon": native.get_item_icon(idx),
				"tooltip": native.get_item_tooltip(idx)
			}
		)
	
	for idx in range(rest_options_idx, native.get_item_count()):
		if native.is_item_separator(idx):
			var btn = add_button("", true, "")
			btn.disabled = true
			btn.focus_mode = Control.FOCUS_NONE
		else:
			var btn = add_button(native.get_item_text(idx), true, str(native.get_item_id(idx)))
			btn.icon = native.get_item_icon(idx)
	
	var cancel_btn = get_cancel_button()
	remove_button(cancel_btn)
	add_button(cancel_btn.text, true, "cancel")
	
	tree.build_from_schemas(schemas)
	
	line_edit.grab_focus()


func _on_ExchangedResourcePicker_popup_hide():
	call_deferred("queue_free")


func _on_ExchangedResourcePicker_confirmed():
	_handle_confirm()


func _on_LineEdit_text_changed(new_text: String):
	var filtered = []
	
	if new_text.is_empty():
		filtered = self.schemas
	else:
		var score_map = {}
		for schema in self.schemas:
			if not new_text.is_subsequence_ofn(schema.text):
				continue
			var score = schema.text.to_lower().similarity(new_text.to_lower())
			filtered.append(schema)
			score_map[schema.id] = score
		filtered.sort_custom(func(a, b): 
			return score_map[a.id] > score_map[b.id]
		)
	tree.build_from_schemas(filtered)


func _on_ExchangedResourcePicker_about_to_show():
	$VBoxContainer/LineEdit.call_deferred('grab_focus')


func _on_Tree_item_double_clicked():
	_handle_confirm()


func _handle_confirm():
	assert(native != null)
	var id = tree.selected_schema_id()
	
	if id == -1:
		return
	
	native.emit_signal("id_pressed", id)
	
	hide()


func _on_Tree_item_activated():
	_handle_confirm()


func _on_ExchangedResourcePicker_custom_action(action):
	if action == "cancel":
		hide()
		return
	
	assert(native != null)
	var id = int(action)
	
	if id == -1:
		return
	
	native.emit_signal("id_pressed", id)
	
	hide()
