require File.dirname(__FILE__) + '/lib/lockbox'
require File.dirname(__FILE__) + '/lib/acts_as_lockbox'
ActiveRecord::Base.send(:include, MashdCc::Acts::Lockbox)
