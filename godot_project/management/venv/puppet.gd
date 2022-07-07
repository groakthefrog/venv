extends Spatial

var puppeteer: int = -1

func _ready():
	add_to_group(Constants.VENV_OBJECT_GROUP_NAME)