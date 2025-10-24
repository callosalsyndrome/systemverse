extends Node2D

# для начала будет достаточно реализовать правильно движение + зону, в которой игроку будет 
# доступно взаимодействие с предметами. 


signal player_initiated_dialogue() #диалог с нпс или взаимодействие с предметом
signal player_initiated_cutscene()
signal player_initiated_combat()
signal checkpoint_reached()
