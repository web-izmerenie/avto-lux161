import hashlib
import crypt
from hmac import compare_digest as compare_hash



## TODO: test this
class AmdinBaseHandler(AbstractRouter):
	def validate_password(self, symbols):
		return True

    def create_password(self, symbols):
    	return str(hashlib.sha224().hexdigest())

    ## Test
    def compare_password(self, password, hpasswd):
    	return compare_hash(hpasswd, crypt.crypt(password, hpasswd))