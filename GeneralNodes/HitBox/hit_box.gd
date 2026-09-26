class_name HitBox extends Area2D

@export var damage : int = 1

signal damaged( hurt_box : HurtBox )


func Take_Damage( hurt_box : HurtBox ) -> void:
	damaged.emit( hurt_box )
