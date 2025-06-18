extends RigidBody3D
 
## How much vertical force to apply when moving
@export_range(750, 3000) var thrust: float = 1000

@export var torque_thrust: float = 100

var is_transitioning: bool = false

## Particles 
@onready var explosion_audio: AudioStreamPlayer = $Audio/ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $Audio/SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $Audio/RocketAudio
@onready var booster_particles: GPUParticles3D = $Particles/BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $Particles/RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $Particles/LeftBoosterParticles

## Particles one shot
@onready var explosion_particles: GPUParticles3D = $ParticlesOneShot/ExplosionParticles
@onready var success_particles: GPUParticles3D = $ParticlesOneShot/SuccessParticles

# Called every frame. 'delta' is the elapsed time the previous frame.
func  _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else: 
		booster_particles.emitting = false
		rocket_audio.stop()
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, torque_thrust * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
	
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -torque_thrust * delta))
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false

func _on_body_entered(body: Node) -> void:
	if !is_transitioning: 
		if  "Goal" in body.get_groups():
			comple_level(body.file_path) 
		if  "Hazard" in body.get_groups():
			crash_sequence()
	
	
func crash_sequence() -> void: 
	explosion_particles.emitting = true
	explosion_audio.play()
	print("Kabum")
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
	
	
func comple_level(next_level_file: String) -> void: 
	success_particles.emitting = true
	success_audio.play()
	print("Level complete")
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
	)
