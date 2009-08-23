require 'openssl'
require 'base64'

class Lockbox

  @@locked = true
  @@public_key = nil
  @@private_key = nil

  def self.locked?
    return @@locked
  end

  def self.unlocked?
    return !@@locked
  end

  def self.try? (pass_phrase)
    config = YAML::load_file("#{RAILS_ROOT}/config/lockbox.yml")[RAILS_ENV]
    if pass_phrase.nil? and config['pass_phrase'].nil?
      false
    else
      begin
        @@public_key = OpenSSL::PKey::RSA.new(File.read(config['public_key_path']))
        @@private_key = OpenSSL::PKey::RSA.new(File.read(config['private_key_path']), pass_phrase||config['pass_phrase'])
        @@locked = false
        true
      rescue OpenSSL::PKey::RSAError
        false
      end
    end
  end

  def self.encrypt(val)
    if locked?
      raise StillLockedException, "Passphrase not provided to lockbox."
    elsif val.is_a? String
      Base64.encode64(@@public_key.public_encrypt(val))
    end
  end

  def self.decrypt(val)
    if locked?
      raise StillLockedException, "Passphrase not provided to lockbox."
    elsif val.is_a? String
      @@private_key.private_decrypt(Base64.decode64(val))
    end
  end

end

class StillLockedException < RuntimeError
end
