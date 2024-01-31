
CA_SUBJECT=/C=US/ST=CA/O=Rocket CA/CN=VioletKeys Root CA
SUBJECT=/C=US/ST=CA/O=VioletKeys/CN=localhost
ALT=DNS:localhost

run: playground/target/debug/playground cert
	echo "done"

playground/target/debug/playground: playground/src/main.rs
	cd playground;cargo build

clean:
	cd playground;cargo clean
	rm -rf cert

cert: cert/ca_cert.pem cert/rsa_sha256.p12 cert/ed25519.p12 cert/ecdsa_nistp256_sha256.p12 cert/ecdsa_nistp384_sha384.p12

cert/ca_cert.pem:
	mkdir -p cert
	cd cert; openssl genrsa -out ca_key.pem 4096
	cd cert; openssl req -new -x509 -days 3650 -key ca_key.pem -subj "$(CA_SUBJECT)" -out ca_cert.pem

cert/rsa_sha256.p12:
	cd cert; openssl req -newkey rsa:4096 -nodes -sha256 -keyout rsa_sha256_key.pem -subj "$(SUBJECT)" -out server.csr
	cd cert; openssl x509 -req -sha256 -ext "subjectAltName=$(ALT)" -days 3650 -CA ca_cert.pem -CAkey ca_key.pem -CAcreateserial -in server.csr -out rsa_sha256_cert.pem
	cd cert; openssl pkcs12 -export -password pass:rocket -in rsa_sha256_cert.pem -inkey rsa_sha256_key.pem -out rsa_sha256.p12

cert/ed25519.p12:
	cd cert; openssl genpkey -algorithm ED25519 > ed25519_key.pem
	cd cert; openssl req -new -key ed25519_key.pem -subj "$(SUBJECT)" -out server.csr
	cd cert; openssl x509 -req -ext "subjectAltName=$(ALT)" -days 3650 -CA ca_cert.pem -CAkey ca_key.pem -CAcreateserial -in server.csr -out ed25519_cert.pem
	cd cert; openssl pkcs12 -export -password pass:rocket -in ed25519_cert.pem -inkey ed25519_key.pem -out ed25519.p12

cert/ecdsa_nistp256_sha256.p12:
	cd cert; openssl ecparam -out ecdsa_nistp256_sha256_key.pem -name prime256v1 -genkey
  	# Convert to pkcs8 format supported by rustls
	cd cert; openssl pkcs8 -topk8 -nocrypt -in ecdsa_nistp256_sha256_key.pem -out ecdsa_nistp256_sha256_key_pkcs8.pem
	cd cert; openssl req -new -nodes -sha256 -key ecdsa_nistp256_sha256_key_pkcs8.pem -subj "$(SUBJECT)" -out server.csr
	cd cert; openssl x509 -req -sha256 -ext "subjectAltName=$(ALT)" -days 3650 -CA ca_cert.pem -CAkey ca_key.pem -CAcreateserial -in server.csr -out ecdsa_nistp256_sha256_cert.pem
	cd cert; openssl pkcs12 -export -password pass:rocket -in ecdsa_nistp256_sha256_cert.pem -inkey ecdsa_nistp256_sha256_key_pkcs8.pem -out ecdsa_nistp256_sha256.p12

cert/ecdsa_nistp384_sha384.p12:
	cd cert; openssl ecparam -out ecdsa_nistp384_sha384_key.pem -name secp384r1 -genkey
	# Convert to pkcs8 format supported by rustls
	cd cert; openssl pkcs8 -topk8 -nocrypt -in ecdsa_nistp384_sha384_key.pem -out ecdsa_nistp384_sha384_key_pkcs8.pem
	cd cert; openssl req -new -nodes -sha384 -key ecdsa_nistp384_sha384_key_pkcs8.pem -subj "$(SUBJECT)" -out server.csr
	cd cert; openssl x509 -req -sha384 -ext "subjectAltName=$(ALT)" -days 3650 -CA ca_cert.pem -CAkey ca_key.pem -CAcreateserial -in server.csr -out ecdsa_nistp384_sha384_cert.pem
	cd cert; openssl pkcs12 -export -password pass:rocket -in ecdsa_nistp384_sha384_cert.pem -inkey ecdsa_nistp384_sha384_key_pkcs8.pem -out ecdsa_nistp384_sha384.p12
