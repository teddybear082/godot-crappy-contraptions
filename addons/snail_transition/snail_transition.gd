extends Node

var _transition_mode := TransitionMode.Full
var _transition_in: PackedScene
var _transition_out: PackedScene
var _current_transition: SceneTransition
var _next_scene: PackedScene

const FADE_IN := preload("res://addons/snail_transition/transitions/FadeIn.tscn")
const FADE_OUT := preload("res://addons/snail_transition/transitions/FadeOut.tscn")

enum TransitionMode {
	In, # switches, then uncovers
	Out, # covers, then switches
	Full, # Out, then In
}

func _run_transition():
	if _transition_out:
		_current_transition = _transition_out.instantiate()
		add_child(_current_transition)
		await _current_transition.finished

	# make sure not to switch mid-frame
	await get_tree().process_frame
	if _next_scene and _next_scene.can_instantiate():
		get_tree().change_scene_to_packed(_next_scene)
		if _current_transition:
			_current_transition.queue_free()
			_current_transition = null

	if _transition_in:
		_current_transition = _transition_in.instantiate()
		add_child(_current_transition)
		await _current_transition.finished
		_current_transition.queue_free()
		_current_transition = null

	_next_scene = null
	_transition_out = null
	_transition_in = null

func auto_transition(p_scene: PackedScene, p_transition_out: PackedScene = FADE_OUT, p_transition_in: PackedScene = FADE_IN):
	if _current_transition:
		_current_transition.hurry()
		await _current_transition.finished
		if _current_transition:
			_current_transition.queue_free()
			_current_transition = null

	_next_scene = p_scene
	_transition_in = p_transition_in
	_transition_out = p_transition_out
	_run_transition()
