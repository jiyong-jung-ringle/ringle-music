private_key_file = Rails.root.join("config", "keys", "private.pem")
SECRET_KEY = OpenSSL::PKey::RSA.new(File.read(private_key_file))