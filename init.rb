require File.dirname(__FILE__) + '/lib/lockbox'
if defined?(ActiveRecord)
  require File.dirname(__FILE__) + '/lib/acts_as_lockbox'
  ActiveRecord::Base.send(:include, MashdCc::Acts::Lockbox)
end
