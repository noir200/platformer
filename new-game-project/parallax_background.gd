extends ParallaxBackground

var scroll_speed = 30.0

func _process(delta):
	scroll_offset.x -= scroll_speed * delta
