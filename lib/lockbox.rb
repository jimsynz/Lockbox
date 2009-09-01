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
