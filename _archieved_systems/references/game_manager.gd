# scripts/core/game_manager.gd
extends Node

signal mission_started
signal mission_completed
signal player_died

#var current_mission: Mission
var player_resources: Dictionary = {}
#var survivors: Array[Survivor] = []

func _ready():
    # Initialize core systems
    pass
