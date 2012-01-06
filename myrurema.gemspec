require File.expand_path('../lib/myrurema/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yutaka HARA"]
  gem.email         = ["yutaka.hara.gmail.com"]
  gem.description   = %q{myrurema provides a command 'rurema', which helps searching/browsing/writing the Japanese Ruby documents (a.k.a Rurema http://bugs.ruby-lang.org/projects/rurema/wiki .)}
  gem.summary       = %q{A tool for Rurema (the new Japanese Ruby reference manual)}
  gem.homepage      = 'http://github.com/yhara/myrurema'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "myrurema"
  gem.require_paths = ['lib']
  gem.version       = MyRurema::VERSION

  gem.add_dependency("launchy", "~> 2.0.5")
  gem.add_development_dependency("rspec", ">= 2.0")
end
