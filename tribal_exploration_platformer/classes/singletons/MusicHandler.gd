extends Node

signal beat(beatNumber)	# Starting with 0
signal bop(bopNumber)	# Starting with 0
signal transition_start()
signal transition_end()
signal bpm_changed(newBPM)

enum MODE {
	SOLO,			# Current Music Stops abruptly; New Music immediately Starts
	FADE,			# Current Music fades out, then new Music fades in
	CROSSFADE,		# Current Music fades to New Music simultaneously
	OVERLAY,		# Current Music is added to new Music
}

const FADE_TIME:float = 5.0
const BEATS_PER_RESYNC:int = 1

var musicCache:Cache = Cache.new(20)

var audioBusses = [
	AudioServer.get_bus_index("Music 1"),
	AudioServer.get_bus_index("Music 2")
]

var audioStreamPlayerDict = {}

var tweenDict = {}
var callbackReferenceDict = {}		# Prevent References from being freed if still used in fades

var tweenCallback = {}

var currentAudioBusId:int = 0
var currentBPM:int = 0 setget setBPM
var currentBPB:int = 4			# Bops per Beat
var beatNumber:int = 0	setget setBeat
var bopNumber:int = 0	setget setBop
var currentBopTime:float = 0

func play(song:Song, mode:int = MODE.SOLO, effectTime:float = FADE_TIME):
	var audioStream = musicCache.loadFromCache(song.resourcePath)
	match mode:
		MODE.SOLO:
			_playSolo(audioStream, currentAudioBusId)
		MODE.FADE:
			_playFade(audioStream, effectTime)
		MODE.CROSSFADE:
			_playCrossFade(audioStream, effectTime)
		MODE.OVERLAY:
			_playOverlay(audioStream, currentAudioBusId)
	self.currentBPM = song.bpm
	


func _ready():
	for audioBusId in audioBusses:
		AudioServer.set_bus_volume_db(audioBusId, -80)
		var tween = Tween.new()
		tween.connect("tween_all_completed", self, "_on_tween_completed", [audioBusId])
		add_child(tween)
		tweenDict[audioBusId] = tween
		callbackReferenceDict[audioBusId] = []
	currentAudioBusId = audioBusses[0]
	
func _process(delta):
	if currentBPM > 0:
		currentBopTime += delta
		if currentBopTime >= ((currentBPM / 60.0) / currentBPB) - AudioServer.get_output_latency():
			currentBopTime -= (currentBPM / 60.0) / currentBPB
			self.bopNumber += 1
			
func _playSolo(song:AudioStream, audioBusId:int = currentAudioBusId, startDB:int = 0):
	AudioServer.set_bus_volume_db(audioBusId, startDB)
	_createAudioStream(audioBusId, song)
	
func _playOverlay(song:AudioStream, audioBusId:int = currentAudioBusId, startDB:int = 0):
	AudioServer.set_bus_volume_db(audioBusId, startDB)
	_createAudioStream(_getNextAudioBus(), song)
	
func _playFade(song:AudioStream, effectTime:float = FADE_TIME):
	var _fadeOutBusId = currentAudioBusId
	var _fadeInBusId = _getNextAudioBus()
	_switchCurrentAudioBus()
	_playSolo(song, _fadeInBusId, -80)
	_fadeOut(_fadeOutBusId, effectTime, Callback.new(funcref(self, "_fadeIn"), [_fadeInBusId, effectTime, Callback.new(funcref(self, "emit_signal"), ["transition_end"])]))
		
func _playCrossFade(song:AudioStream, effectTime:float = FADE_TIME):
	var _fadeOutBusId = currentAudioBusId
	var _fadeInBusId = _getNextAudioBus()
	_switchCurrentAudioBus()
	emit_signal("transition_start")
	_fadeOut(_fadeOutBusId, effectTime)
	_playSolo(song, _fadeInBusId, -80)
	_fadeIn(_fadeInBusId, effectTime, Callback.new(funcref(self, "emit_signal"), ["transition_end"]))
	
func _fadeIn(audioBusId:int = currentAudioBusId, effectTime:float = FADE_TIME, callback:Callback = null):
	_clearTween(audioBusId)
	var method = Callback.new(funcref(AudioServer, "set_bus_volume_db"), [audioBusId])
	callbackReferenceDict[audioBusId].append(method)
	tweenDict[audioBusId].interpolate_method(method, "complete_func", AudioServer.get_bus_volume_db(audioBusId), 0, effectTime, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tweenDict[audioBusId].start()
	setBop(0)
	if callback != null:
		tweenCallback[audioBusId] = callback
	
func _fadeOut(audioBusId:int = currentAudioBusId, effectTime:float = FADE_TIME, callback:Callback = null):
	_clearTween(audioBusId)
	var method = Callback.new(funcref(AudioServer, "set_bus_volume_db"), [audioBusId])
	callbackReferenceDict[audioBusId].append(method)
	tweenDict[audioBusId].interpolate_method(method, "complete_func", AudioServer.get_bus_volume_db(audioBusId), -80, effectTime, Tween.TRANS_QUAD, Tween.EASE_IN)
	tweenDict[audioBusId].start()
	if callback != null:
		tweenCallback[audioBusId] = callback
		
func _resynchronize():
	if audioStreamPlayerDict.has(currentAudioBusId):
		var audioStreamPlayer = audioStreamPlayerDict.get(currentAudioBusId)
		var currentTime = audioStreamPlayer.get_playback_position()
		beatNumber = floor(currentTime / (currentBPM / 60.0))
		bopNumber = floor((currentTime - (beatNumber * (currentBPM / 60.0))) / ((currentBPM / 60.0) / currentBPB))
		currentBopTime = currentTime - (beatNumber * (currentBPM / 60.0)) - (bopNumber * ((currentBPM / 60.0) / currentBPB))
	
func _clearTween(audioBusId:int):
	if tweenCallback.has(audioBusId):
		tweenCallback.erase(audioBusId)
	tweenDict[audioBusId].stop_all()
	tweenDict[audioBusId].remove_all()
	callbackReferenceDict[audioBusId] = []
	
func _getNextAudioBus():
	if currentAudioBusId == audioBusses[0]: return audioBusses[1]
	return audioBusses[0]

func _switchCurrentAudioBus():
	currentAudioBusId = _getNextAudioBus()

func _createAudioStream(audioBusId:int, song:AudioStream):
	var audioStreamPlayer = AudioStreamPlayer.new()
	audioStreamPlayer.stream = song
	audioStreamPlayer.bus = AudioServer.get_bus_name(audioBusId)
	audioStreamPlayer.autoplay = true
	add_child(audioStreamPlayer)
	if audioStreamPlayerDict.has(audioBusId):
		audioStreamPlayerDict.get(audioBusId).call_deferred("queue_free")
	audioStreamPlayerDict[audioBusId] = audioStreamPlayer
	
func _removeAudioStreams(audioBusId:int):
	if audioStreamPlayerDict.has(audioBusId):
		audioStreamPlayerDict.get(audioBusId).call_deferred("queue_free")
		audioStreamPlayerDict.erase(audioBusId)
	
func setBPM(_bpm:int):
	currentBPM = _bpm
	beatNumber = 0
	currentBopTime = -1 * AudioServer.get_time_to_next_mix()
	emit_signal("bpm_changed", currentBPM)
	
func setBeat(_beat:int):
	emit_signal("beat", self.beatNumber)
	beatNumber = _beat
	if beatNumber % BEATS_PER_RESYNC == 0:
		_resynchronize()
	
func setBop(_bop:int):
	emit_signal("bop", self.bopNumber)
	bopNumber = _bop
	if bopNumber % currentBPB == 0:
		bopNumber = 0
		setBeat(self.beatNumber + 1)

func _on_tween_completed(audioBusId):
	if AudioServer.get_bus_volume_db(audioBusId) <= -60:
		_removeAudioStreams(audioBusId)
	if tweenCallback.get(audioBusId, null) != null:
		tweenCallback.get(audioBusId).call_func()
		tweenCallback.erase(audioBusId)
	callbackReferenceDict[audioBusId] = []
		
class Callback:
	static func multi(callbacks:Array):
		for callback in callbacks:
			callback.call_func()	
	
	var ref:FuncRef
	var args:Array
	
	func _init(_ref, _args = []):
		self.ref = _ref
		self.args = _args
		
	func call_func(additionalArgs:Array = []):
		self.ref.call_funcv(self.args + additionalArgs)
		
	func complete_func(additionalArg):
		self.call_func([additionalArg])
		
class Song:
	var resourcePath:String
	var bpm:int
	
	func _init(_path:String, _bpm:int):
		self.resourcePath = _path
		self.bpm = _bpm
