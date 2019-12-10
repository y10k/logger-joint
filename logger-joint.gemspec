# -*- coding: utf-8 -*-

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logger/joint/version"

Gem::Specification.new do |spec|
  spec.name          = "logger-joint"
  spec.version       = Logger::Joint::VERSION
  spec.authors       = ["TOKI Yoshinori"]
  spec.email         = ["toki@freedom.ne.jp"]

  spec.summary       = %q{logger-joint is a utility to joint multiple loggers into one logger.}
  spec.description   = <<-'EOF'
    logger-joint is a utility to joint multiple loggers into one logger.
    Logs can be output to multiple output destinations at the same
    time with one jointed logger.
  EOF
  spec.homepage      = "https://github.com/y10k/logger-joint"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "rdoc"
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
