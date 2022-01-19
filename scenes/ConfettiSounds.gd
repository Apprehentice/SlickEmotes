extends Node

const SOUND_CHANCE = 10

onready var rng : RandomNumberGenerator = RandomNumberGenerator.new();

signal finished;

func _ready():
	rng.randomize();
	if rng.randi_range(1, 100) < SOUND_CHANCE:
		var children = get_children();
		children[rng.randi_range(0, get_children().size() - 1)].play();

func _on_AudioStreamPlayer2D_finished():
	emit_signal("finished");
