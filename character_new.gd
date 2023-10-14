# MAIN character skripts, kas regulē kameras, char. kontroles un char. fiziku

extends CharacterBody3D

# Kustību konstantes
const SPEED 					= 5.0
const JUMP_VELOCITY 			= 4.5
const FRICTION 					= 210
const HORIZONTAL_ACCELERATION 	= 30
const MAX_SPEED 				= 5

# Definējam gravitāciju (lai tā strādā, bet visticamāk to nāksies noņemt).
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Definējam dažādas character kamaras
@onready var def_camera = $Camera3D 				# Default kamera					0.
@onready var alt_camera = $CameraOrto3D 			# Orogrāfiskais kameras režīms		1.
@onready var stp_camera = $Camera_step_test			# Kāpņu "collision" test kamera		2.
@onready var cam_button = get_node("../CamButton") 	# GUI poga lai mainītu kameru
var cam_mode = 1	# Kameras maiņa secībā pēc kārtas (uzreiz mainot no def_camera uz alt_camera)

# Peles inputs
func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
	# Pievienojam iespēju mainīt kameras režīmu (drīzāk switch starp 2 kamerām)
	cam_button.pressed.connect(self._kad_cam_poga_tiek_uzpiesta)

# GUI kameras poga
func _kad_cam_poga_tiek_uzpiesta():
	# Ja kursors ir redzams un Spacebar (lekšana) nenotiek = drīkst mainīt kameras režīmu
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and Input.is_action_just_pressed("ui_accept") == false:
		if cam_mode == 0:
			print("parasts")
			def_camera.make_current()
			cam_mode = 1
			
		elif cam_mode == 1:
			print("orto")
			alt_camera.make_current()
			cam_mode = 2
			
		else:
			print("step")
			stp_camera.make_current()
			cam_mode = 0
			
	
func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Gravitācija jeb paātrināta krišana lejup, ja esam gaisā
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Palekšanās
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		velocity.y += JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Vector3.ZERO
	var movetoward = Vector3.ZERO
	input_dir.x = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").x
	input_dir.y = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").y
	input_dir=input_dir.normalized()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction *= SPEED
	velocity.x = move_toward(velocity.x,direction.x, HORIZONTAL_ACCELERATION * delta)
	velocity.z = move_toward(velocity.z,direction.z, HORIZONTAL_ACCELERATION * delta)

	var angle=5 # kameras leņķa nobīde kad protagonists kustās
	#rotation_degrees=Vector3(input_dir.normalized().y*angle,rotation_degrees.y,-input_dir.normalized().x*angle)
	var t = delta * 6
	if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED: 
		rotation_degrees=rotation_degrees.lerp(Vector3(input_dir.normalized().y*angle,rotation_degrees.y,-input_dir.normalized().x*angle),t)
	
	move_and_slide()
	force_update_transform()

## Funkcija kas dod iespēju kamerai sekot kursoram. (Šo iespēju nevajag)
#func _unhandled_input(event):
#	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
#		rotate_y(-event.relative.x * .005)
#		def_camera.rotate_x(-event.relative.y * .005)
#		def_camera.rotation.x = clamp(def_camera.rotation.x, -PI/2, PI/2)
