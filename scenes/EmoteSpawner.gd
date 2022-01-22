extends Node2D
class_name EmoteSpawner

onready var emote_scene : Resource = preload("res://scenes/Emote.tscn");
onready var rng : RandomNumberGenerator = RandomNumberGenerator.new();

export var Url : String;
export var Party : bool = false;

var spawning : bool = false;

func _ready():
	rng.randomize();

func BeginSpawn() -> void:
	if (spawning):
		return;
		
	spawning = true;
	$HTTPRequest.connect("request_completed", self, "_req_completed")
	$HTTPRequest.request(Url);

func _req_completed(result, response_code, headers, body):
	if response_code != 200:
		return;
		
	var image : Image = Image.new();
	var error = image.load_png_from_buffer(body);
	if error != OK:
		return;
		
	var texture : ImageTexture = ImageTexture.new();
	texture.create_from_image(image);
	
	var e : Node = emote_scene.instance();
	
	var emote_image : Node = e.get_node("Image");
	emote_image.texture = texture;
	
	var transform : Transform2D = get_viewport_transform();
	var scale : Vector2 = transform.get_scale();
	var newPos : Vector2 = (-transform.origin / scale + get_viewport_rect().size / scale) * Vector2(rng.randf(), rng.randf());
	
	e.position = newPos;
	e.Party = Party;
	get_parent().add_child(e);
	get_parent().remove_child(self);
