extends Node

# vars regarding what the player can move
var player_can_move: bool = true
var player_can_interact: bool = true

# Tracks the current interaction type to gate shared dialogue signals. Dialogic signals are 
# global, so all interactables connected to them will receive the signal. Without this state 
# check, ending one dialogue (e.g. basic dialogue) could incorrectly trigger logic from other 
# interaction types (such as animation-based interactions).
var interaction_state: String = ""
