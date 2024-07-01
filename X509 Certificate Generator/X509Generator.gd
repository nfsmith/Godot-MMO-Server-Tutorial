extends Node

var X509_cert_filename = "X509_Certificate.crt"
var X509_key_filename = "x509_Key.key"
@onready var X509_cert_path = "user://Certificate/" + X509_cert_filename
@onready var X509_key_path = "user://Certificate/" + X509_key_filename

var CN = "MultiplayerTutorial"
var O = "GameDevelopmentCenter"
var C = "NL"
var not_before = "20201023000000"
var not_after = "20251022235900"

# Called when the node enters the scene tree for the first time.
func _ready():
	if DirAccess.dir_exists_absolute("user://Certificate"):
		pass
	else:
		DirAccess.make_dir_absolute("user://Certificate")
	CreateX589Cert()
	print("Certificate Created")
	
func CreateX589Cert():
	var CNOC = "CN=" + CN + ",0=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
