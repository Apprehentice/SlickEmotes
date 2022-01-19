extends RigidBody2D

onready var rng : RandomNumberGenerator = RandomNumberGenerator.new();
onready var confetti = preload("res://scenes/Confetti.tscn");
onready var has_popped = false;

export var Force : int = 250;
export var AngularForce : int = 10;
export var party = true;

signal popped

func _ready():
	rng.randomize();
	self.linear_velocity = Vector2(rng.randf_range(-1, 1), 1) * (Force * -1);
	self.angular_velocity = rng.randf_range(-1, 1) * AngularForce;

func _process(delta):
	var transform : Transform2D = get_viewport_transform();
	var scale : Vector2 = transform.get_scale();
	if (position.y > (-transform.origin / scale + get_viewport_rect().size / scale).y):
		queue_free();


func _on_Emote_body_entered(body):
	if (party and not has_popped):
		var c = confetti.instance();
		c.position = self.position;
		c.emitting = true;
	
		get_tree().current_scene.add_child(c);
		has_popped = true;
		get_tree().call_group("PopListeners", "emote_popped")
