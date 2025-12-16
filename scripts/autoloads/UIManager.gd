extends Node

# ссылки на все игровые ui-элементы будут находиться здесь
# подписывается на сигналы других менеджеров 
# тут ничего нет, но в будущем пригодится для нормальной архитектуры.

#главное меню
signal main_menu_play_pressed()
signal main_menu_exit_pressed()

#меню паузы
signal pause_resume_pressed()
signal pause_guit_to_menu_pressed()
