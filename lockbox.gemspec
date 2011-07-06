# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lockbox}
  s.version = "2011.7.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Harton"]
  s.date = %q{2011-07-06}
  s.email = %q{james@sociable.co.nz}
  s.files = ["MPL-LICENSE", "README", "Rakefile", "TODO", "init.rb", "install.rb", "lockbox.gemspec", "lib/lockbox.rb", "lib/acts_as_lockbox.rb", "tasks/lockbox_tasks.rake", "test/lockbox_test.rb", "test/test_helper.rb", "test/private.pem", "test/public.pem", "uninstall.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://github.com/jamesotron/Lockbox}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Reversible, secure secret storing for your rails model using public/private key encryption and acts_as_lockbox.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
