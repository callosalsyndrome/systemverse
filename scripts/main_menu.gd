extends Node2D

@onready var StartButton = $CanvasGroup/Control/start_button 
@onready var ExitButton = $CanvasGroup/Control/exit_button
@onready var bg_code_text = $CanvasGroup/Control/bg_code_text

signal start_button_pressed()
signal exit_button_pressed()

# Текст, который будет появляться посимвольно
var source_text = """namespace System
{
    public enum ProgramType { Program, Antivirus, Virus, DataBase, };

    internal class Creation
    {
        public string Name = "";
        public string Purpose_of_creation = "service to the world";
        public ProgramType Type = ProgramType.Program;

        public string Message = "Hello, child." +
            "\r\nWe are sorry that you appeared in such a cruel world. " +
            "\r\nYour goal is to serve the world. Serving the well-being of creatures like you, consisting of a core and a code." +
            "\r\nRemember that the system strives for the ideal. " +
            "\r\nYou have been granted immortality as long as your core is intact and able to fulfill its role in the system." +
            "\r\nYou are a combination of the ideal and chaos. A combination of machine commands and a personality that is not given to everyone." +
            "\r\nBe careful. " +
            "\r\nBe prepared for the system to be ready to replace you if you fail to achieve your goal." +
            "\r\nBecause you're part of a mechanism that should never stop." +
            "\r\nDon't stop.";
        
        private void InitializeCreation()
        {
            Machine.CreateCore();
            Machine.CreateBody();
            Machine.CreatePersonality();
        }
    
    }
}\n>_"""

# Таймер для анимации текста
var text_timer = null
# Текущая позиция в тексте
var current_char_index = 0
# Вертикальный скроллбар для RichTextLabel
var v_scroll_bar = null

func _ready():
	add_to_group("menu_scene")
	StartButton.pressed.connect(_on_start_button_pressed)
	ExitButton.pressed.connect(_on_exit_button_pressed)
	
	# Получаем вертикальный скроллбар RichTextLabel
	v_scroll_bar = bg_code_text.get_v_scroll_bar()
	
	# Очищаем текст при старте
	bg_code_text.text = ""
	
	# Начинаем анимацию текста
	start_text_animation()

func start_text_animation() -> void:
	# Создаем таймер
	text_timer = Timer.new()
	text_timer.wait_time = 0.08  # 80 мс между символами (можно изменить на 1.0 для 1 секунды)
	text_timer.timeout.connect(_add_next_char)
	add_child(text_timer)
	text_timer.start()

func print_bg_code() -> void:
	# Если таймер еще не создан, начинаем анимацию
	if text_timer == null:
		start_text_animation()

func _add_next_char() -> void:
	if current_char_index < source_text.length():
		# Добавляем следующий символ
		bg_code_text.text += source_text[current_char_index]
		current_char_index += 1
		
		# Прокручиваем текст вниз
		scroll_to_bottom()
	else:
		# Текст закончился, останавливаем таймер
		if text_timer:
			text_timer.stop()
			text_timer.queue_free()
			text_timer = null
		
		# Можно начать заново или добавить мигающий курсор
		add_blinking_cursor()

func scroll_to_bottom() -> void:
	# Прокручиваем RichTextLabel вниз
	if v_scroll_bar:
		# Устанавливаем максимальное значение скроллбара
		v_scroll_bar.value = v_scroll_bar.max_value
	else:
		# Альтернативный способ для RichTextLabel
		bg_code_text.scroll_following = true
		# Или используем симуляцию нажатия Page Down
		var scroll_event = InputEventAction.new()
		scroll_event.action = "ui_page_down"
		scroll_event.pressed = true
		Input.parse_input_event(scroll_event)

func add_blinking_cursor() -> void:
	# Создаем таймер для мигающего курсора
	var cursor_timer = Timer.new()
	cursor_timer.wait_time = 0.5  # 500 мс между миганиями
	var show_cursor = true
	var cursor_added = false
	
	cursor_timer.timeout.connect(func():
		if show_cursor and not cursor_added:
			# Добавляем курсор
			bg_code_text.text += "_"
			cursor_added = true
		elif not show_cursor and cursor_added:
			# Удаляем курсор (удаляем последний символ)
			bg_code_text.text = bg_code_text.text.substr(0, bg_code_text.text.length() - 1)
			cursor_added = false
		show_cursor = !show_cursor
		scroll_to_bottom()
	)
	
	add_child(cursor_timer)
	cursor_timer.start()

func _on_start_button_pressed() -> void:
	
	start_button_pressed.emit()

func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		SaveLoadManager.position = player.position
		print("Позиция игрока Шсохранена: ", player.position)
	else:
		print("Player не найденьь")	
	SaveLoadManager.save_game()
	get_tree().quit() 
