require 'openssl'
require 'base64'
require 'digest/sha2'

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

  def self.try? (pass_phrase, once=false)
    @@once = once
    @@config ||= YAML::load_file("#{RAILS_ROOT}/config/lockbox.yml")[RAILS_ENV]
    if pass_phrase.nil? and @@config['pass_phrase'].nil?
      false
    else
      begin
        @@private_key = OpenSSL::PKey::RSA.new(File.read(@@config['private_key_path']), pass_phrase||@@config['pass_phrase'])
        @@locked = false
        true
      rescue OpenSSL::PKey::RSAError
        false
      end
    end
  end

  def self.lock!
    @@private_key = nil
    @@locked = true
  end

  def self.encrypt(val)
    if val.is_a? String
      @@config ||= YAML::load_file("#{RAILS_ROOT}/config/lockbox.yml")[RAILS_ENV]
      if @@public_key.nil?
        begin
          @@public_key = OpenSSL::PKey::RSA.new(File.read(@@config['public_key_path']))
        rescue
          return false
        end
      end
      # hash the value to make sure that it can't be modified
      # since we might potentially have to split the value
      # into chunks.
      hash = Digest::SHA2.new(256)
      hash << val
      max_size = (@@public_key.n.to_i.to_s(2).size / 8) - 11
      (([ hash.to_s ] +  val.scan(Regexp.new ".{1,#{max_size}}")).collect { |part| @@public_key.public_encrypt(part) }).to_yaml
    end
  end

  def self.decrypt(val)
    if locked?
      raise StillLockedException, "Passphrase not provided to lockbox."
    elsif val.is_a? String
      yaml = YAML::load(val)
      if (yaml.is_a? Array) && (yaml.size > 1)
        decrypted = yaml.collect { |part| @@private_key.private_decrypt(part) }
        hash = decrypted[0]
        value = decrypted[1..-1] * ""
        check = Digest::SHA2.new(256)
        check << value
        if check.to_s == hash
          decoded = value
        else
          raise HashVerificationFailedException, "SHA2 hash digest mismatch."
        end
      elsif yaml.is_a? String
        decoded = @@private_key.private_decrypt(Base64.decode64(val))
      end
      lock! if @@once
      decoded
    end
  end

end

class StillLockedException < RuntimeError
end
class HashVerificationFailedException < RuntimeError
end
