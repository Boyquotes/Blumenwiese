extends Control


const MAX_PLAYERS := 4

const Logger = preload("res://util/Logger.gd")
var logger: Logger

var server_port := 9000

var player_node_template: Control

var local_profiles: Array # of NetworkPlayer

func _init():
	._init()
	logger = Logger.new("NetStartMenu")
	logger.level = Logger.Level.DEBUG
	logger.name += (get_instance_id() as String)

# Called when the node enters the scene tree for the first time.
func _ready():
	player_node_template = $VBoxContainer/LocalProfiles/ScrollContainer/LocalProfiles/DummyPlayer
	player_node_template.hide()
	var mp = get_tree().multiplayer
	mp.connect("server_disconnected", self, "on_server_disconnected")
	mp.connect("connected_to_server", self, "on_connected_to_server")
	mp.connect("connection_failed", self, "on_connection_failed")
	mp.connect("network_peer_connected", self, "on_network_peer_connected")
	mp.connect("network_peer_disconnected", self, "on_network_peer_disconnected")
	load_local_profiles()
	
func load_local_profiles():
	local_profiles = NetworkPlayer.load_all_local()
	show_local_profiles()

func show_local_profiles():
	var container = $VBoxContainer/LocalProfiles/ScrollContainer/LocalProfiles
	for child in container.get_children():
		if child.name.begins_with("Icon"):
			child.queue_free()
	for nw_player in local_profiles:
		show_local_profile(nw_player)
		
func show_local_profile(nw_player: NetworkPlayer):
	var container = $VBoxContainer/LocalProfiles/ScrollContainer/LocalProfiles
	var btn_add = $VBoxContainer/LocalProfiles/ScrollContainer/LocalProfiles/BtnAdd
	print("show ", nw_player.nickname)
	var pn = player_node_template.duplicate()
	var index = container.get_child_count() - 1
	pn.name = "Icon#%d" % index
	pn.get_node("Col1").color = nw_player.fav_color1
	pn.get_node("Col2").color = nw_player.fav_color2
	pn.get_node("Nickname").text = nw_player.nickname
	container.add_child(pn)
	container.move_child(pn, index)
	pn.visible = true

func on_connected_to_server():
	print("Connected to server!")

func on_connection_failed():
	print("Connection failed!")
	
func on_network_peer_connected(id: int):
	print("Peer connected: ", id)

func on_network_peer_disconnected(id: int):
	print("Peer disconnected: ", id)
	
func on_server_disconnected():
	print("Server disconnected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayerName_text_changed(new_text: String):
	print("Name changed: ", new_text)


func _on_BtnServer_pressed():
	var server_host = $VBoxContainer/HBoxContainer2/TxtHost.text
	server_port = $VBoxContainer/HBoxContainer2/TxtHost.text as int
	print("Starting Server ", server_host, ":", server_port, " -- Note that the host is actually ignored!")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(server_port, MAX_PLAYERS)
	get_tree().network_peer = peer
	show_our_network_role()

func _on_BtnClient_pressed():
	var server_host = $VBoxContainer/HBoxContainer2/TxtHost.text
	server_port = $VBoxContainer/HBoxContainer2/TxtHost.text as int
	print("Starting Client, connecting to ", server_host, ":", server_port)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_host, server_port)
	get_tree().network_peer = peer
	show_our_network_role()
	
func show_our_network_role():
	print("Our network role is: Server? " + (get_tree().is_network_server() as String) + ", unique id=", get_tree().get_network_unique_id())



func _on_BtnAdd_pressed():
	# Create a new local profile.
	$DlgCreateProfile.popup_centered()


func _on_DlgCreateProfile_profile_created(nw_player: NetworkPlayer):
	print("New profile created: ", nw_player.nickname)
	show_local_profile(nw_player)

func _on_DlgCreateProfile_profile_edited(nw_player: NetworkPlayer):
	print("TODO: Profile edited: ", nw_player.nickname)
