class_name Plant extends Node2D

func _ready():
	$HitBox.damaged.connect(Takedamage)

func Takedamage(hurt_box: HurtBox) -> void:
	queue_free()
