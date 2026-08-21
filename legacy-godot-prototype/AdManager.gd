extends Node

signal ad_finished

const INTERSTITIAL_ID = "ca-app-pub-1028468738596053/8793827847"

var _ads = null
var _loaded = false

func _ready():
    if Engine.has_singleton("PoingGodotAdmobAds"):
        _ads = Engine.get_singleton("PoingGodotAdmobAds")
        _ads.interstitial_ad_loaded.connect(_on_loaded)
        _ads.interstitial_ad_dismissed_full_screen_content.connect(_on_closed)
        _load()

func _load():
    if _ads:
        _ads.load_interstitial_ad(INTERSTITIAL_ID)

func show_interstitial():
    if _ads and _loaded:
        _ads.show_interstitial_ad()
    else:
        emit_signal("ad_finished")

func _on_loaded():
    _loaded = true

func _on_closed():
    _loaded = false
    emit_signal("ad_finished")
    _load()
