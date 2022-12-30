private_key_file = Rails.root.join("config", "keys", "private.pem")
public_key_file = Rails.root.join("config", "keys", "public.pem")
SECRET_KEY = OpenSSL::PKey::RSA.new(File.read(private_key_file))
PUBLIC_KEY = OpenSSL::PKey::RSA.new(File.read(public_key_file))