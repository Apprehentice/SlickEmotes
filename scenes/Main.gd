extends Node2D

onready var emote_scene : Resource = preload("res://scenes/Emote.tscn");
onready var rng : RandomNumberGenerator = RandomNumberGenerator.new();
onready var emote_callback : JavaScriptObject = JavaScript.create_callback(self, "emote")
onready var party_callback : JavaScriptObject = JavaScript.create_callback(self, "js_set_party")
onready var clear_callback : JavaScriptObject = JavaScript.create_callback(self, "clear_emotes")
onready var combo_container = $CanvasLayer/VBoxContainer/ComboContainer

export var party : bool = true

var combo : int = 0
var emote_queue : Array = []

const MAX_EMOTES = 50

signal combo

func _ready():
	get_tree().get_root().set_transparent_background(true);
	rng.randomize();
	
	var Emote : JavaScriptObject = JavaScript.get_interface("Emote");
	
	if OS.has_feature("JavaScript"):
		Emote.createEmote = emote_callback;
		Emote.setParty = party_callback;
		Emote.clear = clear_callback;

func _process(delta):
	var activeEmotes : int = $EmoteContainer.get_child_count()
	var added : int = 0
	while (activeEmotes + added < MAX_EMOTES and emote_queue.size() > 0):
		var c = emote_queue.pop_front()
		$EmoteContainer.add_child(c)
		added += 1
	
	if combo > 0 and $EmoteContainer.get_child_count() == 0:
		combo = 0
		emit_signal("combo", combo)
		for c in $HttpRequestContainer.get_children():
			c.queue_free()

func _input(event):
	if not (event is InputEventMouseButton):
		return;
	
	var e : Node = emote_scene.instance();
	var transform : Transform2D = get_viewport_transform();
	var scale : Vector2 = transform.get_scale();
	var newPos : Vector2 = (-transform.origin / scale + get_viewport_rect().size / scale) * Vector2(rng.randf(), rng.randf());
	
	e.position = newPos;
	e.party = party
	emote_queue.push_back(e)

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
	e.party = party
	emote_queue.push_back(e)

func emote_popped():
	combo += 1
	emit_signal("combo", combo)

func emote(args):
	var url : String = args[0];
	var req : HTTPRequest = HTTPRequest.new();
	$HttpRequestContainer.add_child(req)
	req.connect("request_completed", self, "_req_completed")
	req.request(url);

func js_set_party(args):
	party = args[0]

func clear_emotes(args):
	for c in $EmoteContainer.get_children():
		c.queue_free()
	
	while emote_queue.size() > 0:
		emote_queue.pop_front().queue_free()
