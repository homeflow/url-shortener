require 'digest/md5'

class TokenGenerator
	ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(//)
	MAX_DIGITS = 5
	
	def generate_token(url)
		base62_encode(hash(url))
	end

	private 

	def base62_encode(i)
		return ALPHABET[0] if i == 0
		s = ''
		base = ALPHABET.length
		while i > 0
			s << ALPHABET[i.modulo(base)]
			i /= base
		end
		s.reverse
	end

	def hash(str)
		Digest::SHA1.hexdigest(str).to_i(16) % (ALPHABET.length ** MAX_DIGITS)
	end
end
