extends TextureRect

@onready var item_pic: TextureRect = $ItemPic
var item: Item = null


func set_item(new_item: Item) -> void:
	item = new_item
	if item:
		item_pic.texture = new_item.item_sprite


func reset() -> void:
	item = null
	item_pic.texture = null