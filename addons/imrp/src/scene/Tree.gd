tool
extends Tree


func build_from_schemas(schemas):
	clear()
	set_hide_root(true)
	
	var root = create_item()

	for schema in schemas:
		var item = create_item(root)
		
		if schema['id'] < 0:
			item.set_selectable(0, false)
		else:
			item.set_tooltip(0, schema['tooltip'])
			item.set_icon(0, schema['icon'])
			item.set_text(0, schema['text'])
			item.set_metadata(0, schema['id'])


func selected_schema_id():
	var selected = get_selected()
	
	if selected == null:
		return -1
	
	return selected.get_metadata(0)
