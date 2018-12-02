# requires pyjwt (https://pyjwt.readthedocs.io/en/latest/)
# pip install pyjwt


import datetime
import jwt


secret = """-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgFtYt+2X0315Ffjd/
8BPk9ze92ifzFf6TL7pb9ULKw0ugCgYIKoZIzj0DAQehRANCAASoG4aei1IPyiBQ
RYKfVC7YvgUxk+QXp64kwQXcKzSV7e6PZ4U5wN0rpW7bh1AkzvAHTUfks9CQU66t
kDTGe35v
-----END PRIVATE KEY-----"""
keyId = "GGK5N5A2NG"
teamId = "9L3D676U25"
alg = 'ES256'

time_now = datetime.datetime.now()
time_expired = datetime.datetime.now() + datetime.timedelta(hours=12)

headers = {
	"alg": alg,
	"kid": keyId
}

payload = {
	"iss": teamId,
	"exp": int(time_expired.strftime("%s")),
	"iat": int(time_now.strftime("%s"))
}


if __name__ == "__main__":
	"""Create an auth token"""
	token = jwt.encode(payload, secret, algorithm=alg, headers=headers)

	print "----TOKEN----"
	print token

	print "----CURL----"
	print "curl -v -H 'Authorization: Bearer %s' \"https://api.music.apple.com/v1/catalog/us/artists/36954\" " % (token)