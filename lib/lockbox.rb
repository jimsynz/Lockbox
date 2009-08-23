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

  def self.lock!
    @@public_key = nil
    @@private_key = nil
    @@locked = true
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

module MashdCc
  module Acts 
    module Lockbox 

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_lockbox(*opts)
          # Add the standard Lockbox API to the Model.
          self.class_eval <<-RUBY
            
            def self.locked?
              ::Lockbox.locked?
            end

            def self.unlocked?
              ::Lockbox.unlocked?
            end

            def self.try? (pass_phrase)
              ::Lockbox.try? pass_phrase
            end

            def self.lock!
              ::Lockbox.lock!
            end

          RUBY
          opts.each do |opt|
            if opt.is_a? Hash and opt.key? :for
              opt[:for].each do |field|
                self.class_eval <<-RUBY

                  def #{field}
                    ::Lockbox.decrypt(read_attribute(:#{field}))
                  end

                  def #{field}=(val)
                    write_attribute(:#{field}, ::Lockbox.encrypt(val))
                  end

                RUBY
              end
            end
          end

        end
      end

    end
  end
end
