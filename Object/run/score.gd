extends Node

class_name Run_ScooreHandler

var current_session_score := 0


func push(score: int) -> void:
	current_session_score += score
