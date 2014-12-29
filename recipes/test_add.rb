wormly_public_collectd "install wormly " do
	key "myapikey"
	hostname "some-hostname"
	hostid "1111111"
	wormlyhost "http://localhost"
	verifyssl false
	mysqlpassword "password"
	mysqluser "root"
end
