extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts
var experience = 0 setget set_experience
var magic = 0 setget set_magic

var heart_width = 4  # Width of a heart in pixels

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var expBarEmpty = $ExpBarEmpty
onready var expBarFull = $ExpBarFull
onready var magicBarEmpty = $MagicBarEmpty
onready var magicBarFull = $MagicBarFull


func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	heartUIFull.rect_size.x = hearts * heart_width


func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	heartUIEmpty.rect_size.x = max_hearts * heart_width


func set_experience(value):
	experience = value
	var exp_bar_len = expBarEmpty.rect_size.x
	var percent_full = float(experience) / float(PlayerStats.next_level_exp_threshold)
	expBarFull.rect_size.x = int(exp_bar_len * percent_full)


func set_magic(value):
	magic = value
	var mag_bar_len = magicBarEmpty.rect_size.x
	var percent_full = float(magic) / float(PlayerStats.max_magic)
	magicBarFull.rect_size.x = int(mag_bar_len * percent_full)


func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	self.experience = PlayerStats.experience
	self.magic = PlayerStats.magic

	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	PlayerStats.connect("experience_changed", self, "set_experience")
	PlayerStats.connect("magic_changed", self, "set_magic")
	PlayerStats.connect("max_magic_changed", self, "set_magic")
