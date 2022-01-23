tool
extends ConfirmationDialog

onready var tree : Tree = $VBoxContainer/Tree

var native : PopupMenu
var schemas = []


func decorate(native: PopupMenu):
	native.call_deferred("hide")
	
	self.native = native
	self.schemas = []
	
	var rest_options_idx = -1
	
	for idx in range(native.get_item_count()):
		if native.get_item_id(idx) < 0:
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
		var btn = add_button(native.get_item_text(idx), true, str(native.get_item_id(idx)))
		btn.icon = native.get_item_icon(idx)
	
	var cancel_btn = get_cancel()
	remove_button(cancel_btn)
	add_button(cancel_btn.text, true, "cancel")
	
	tree.build_from_schemas(schemas)


func _on_ExchangedResourcePicker_popup_hide():
	call_deferred("queue_free")


func _on_ExchangedResourcePicker_confirmed():
	_handle_confirm()


func _on_LineEdit_text_changed(new_text: String):
	var filtered = []
	
	if new_text.empty():
		filtered = self.schemas
	else:
		for schema in self.schemas:
			if schema['text'].findn(new_text) > -1:
				filtered.append(schema)
	
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
