extends Node

# База данных о предметах. Сделана таким образом, чтобы можно было легко менять названия и описания, ну и некоторые свойства как usable/reusable
# Глобальный скрипт

const TEXTURE_PATH: String = "res://Art/Items/"
const JSON_PATH: String = "res://Data/ItemData.json"

var items: Dictionary = {}


func _ready() -> void:
    load_items()


# Подгружаем все данные из файла JSON, а также находим соответствующую картинку в TEXTURE_PATH
# Поэтому важно, чтобы в данной папке были картинки с таким же названием (item_id)
# Из GlobalManager берем функцию, которую данный предмет будет выполнять. Также используя его id
func load_items() -> void:
    var file: FileAccess = FileAccess.open(JSON_PATH, FileAccess.READ)
    if file:
        var file_data: String = file.get_as_text()
        var json: Object = JSON.new()
        var parse_res: int = json.parse(file_data)
        if parse_res == OK:
            var parsed_json: Array = json.get_data()
            for item_data: Variant in parsed_json:
                var item: Item = Item.new()
                item.item_id = item_data["id"]
                item.item_name = item_data["name"]
                item.description = item_data["description"]
                item.item_sprite = load(TEXTURE_PATH + item.item_id + ".png")

                if "is_usable" in item_data:
                    item.is_usable = item_data["is_usable"]
                if "is_reusable" in item_data:
                    item.is_reusable = item_data["is_reusable"]

                if item.is_usable == true:
                    item.set_use_func(GlobalManager.item_function(item.item_id))

                items[item.item_id] = item
                
            file.close()
        else:
            printerr("Error parsing JSON.")


func get_item(item_id: String) -> Item:
    return items.get(item_id, null)