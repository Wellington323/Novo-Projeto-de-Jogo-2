class_name Player extends CharacterBody2D

signal DirectionChanged( new_direction: Vector2 )
signal player_damaged( hit_box : HitBox )

const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player : AnimationPlayer = $EffectAnimationPlayer
@onready var hit_box : HitBox = $HitBox
@onready var hurt_box : HurtBox = $HurtBox
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : PlayerStateMachine = $StateMachine


func _ready() -> void:
	PlayerManager.player = self
	state_machine.Initialize( self )
	update_hp( 99 )


func _process( _delta : float ) -> void:
	direction = Vector2(
		Input.get_axis( "left", "right" ),
		Input.get_axis( "up", "down" )
	).normalized()


func _physics_process( _delta : float ) -> void:
	move_and_slide()


func SetDirection() -> bool:
	if direction == Vector2.ZERO:
		return false
	   
	var direction_id : int = int( round( ( direction + cardinal_direction * 0.1 ).angle() / TAU * DIR_4.size() ) )
	var new_dir = DIR_4[ direction_id ]
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	DirectionChanged.emit( new_dir )
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true


func set_direction() -> bool:
	return SetDirection()


func UpdateAnimation( state : String ) -> void:
	animation_player.play( state + "_" + AnimDirection() )


func update_animation( state : String ) -> void:
	UpdateAnimation( state )


func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"


# Recebe a HitBox que te atacou
func _take_damage( hit_box_attacker : HitBox, _my_hurt_box : HurtBox = null ) -> void:
	if invulnerable:
		return
		
	update_hp( -hit_box_attacker.damage )
	
	# Envia a HitBox do atacante para calcular o knockback no State_Stun
	player_damaged.emit( hit_box_attacker )
	
	if hp <= 0:
		update_hp( 99 ) # Reseta a vida para testes


func update_hp( delta : int ) -> void:
	hp = clampi( hp + delta, 0, max_hp )


func make_invulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	if hurt_box:
		hurt_box.monitoring = false
		hurt_box.monitorable = false
	
	await get_tree().create_timer( _duration ).timeout
	
	invulnerable = false
	if hurt_box:
		hurt_box.monitoring = true
		hurt_box.monitorable = true
