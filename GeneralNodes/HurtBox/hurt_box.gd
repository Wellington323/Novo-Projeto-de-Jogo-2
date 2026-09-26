class_name HurtBox extends Area2D


func _ready() -> void:
	if not area_entered.is_connected( AreaEntered ):
		area_entered.connect( AreaEntered )


func AreaEntered( a : Area2D ) -> void:
	if a is HitBox:
		# 1. Avisa a HitBox que o golpe acertou
		a.Take_Damage( self )
		
		# 2. Repassa a HitBox que atacou (com o dano) e a HurtBox (que recebeu) para o dono
		if owner and owner.has_method( "_take_damage" ):
			owner._take_damage( a, self )
		elif owner and owner.has_method( "take_damage" ):
			owner.take_damage( a, self )
