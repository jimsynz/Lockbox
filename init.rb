require File.dirname(__FILE__) + '/lib/lockbox'
ActiveRecord::Base.send(:include, MashdCc::Acts::Lockbox)
