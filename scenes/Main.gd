extends Node2D

onready var emote_spawner_scene : Resource = preload("res://scenes/EmoteSpawner.tscn");
onready var emote_callback : JavaScriptObject = JavaScript.create_callback(self, "emote");
onready var clear_callback : JavaScriptObject = JavaScript.create_callback(self, "clear_emotes");
onready var combo_container = $CanvasLayer/VBoxContainer/ComboContainer;

const default_url : String = "https://static-cdn.jtvnw.net/emoticons/v2/25/default/dark/1.0";

var combo : int = 0;

const MAX_EMOTES = 50

signal combo

func _ready():
	get_tree().get_root().set_transparent_background(true);
	
	var Emote : JavaScriptObject = JavaScript.get_interface("Emote");
	
	if OS.has_feature("JavaScript"):
		Emote.createEmote = emote_callback;
		Emote.clear = clear_callback;

func _process(delta):
	var activeEmotes : int = 0;
	for e in $EmoteContainer.get_children():
		if e is Emote and e.is_physics_processing():
			activeEmotes += 1;
		
	var added : int = 0;
	for e in $EmoteContainer.get_children():
		if activeEmotes + added >= MAX_EMOTES:
			break;
		
		if e is EmoteSpawner:
			e.BeginSpawn();
			added += 1;
	
	if combo > 0 and $EmoteContainer.get_child_count() == 0:
		combo = 0
		emit_signal("combo", combo)

func _input(event):
	if not (event is InputEventMouseButton):
		return;
	
	var e : Node = emote_spawner_scene.instance();
	e.Url = default_url;
	e.Party = true;
	$EmoteContainer.add_child(e);
	

func emote_popped():
	combo += 1
	emit_signal("combo", combo)

func emote(args):
	var url : String = args[0];
	var party : bool = args[1];
	var e : Node = emote_spawner_scene.instance();
	e.Url = url;
	e.Party = party;
	$EmoteContainer.add_child(e);

func clear_emotes(args):
	for c in $EmoteContainer.get_children():
		c.queue_free()
