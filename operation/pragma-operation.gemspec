# frozen_string_literal: true

require_relative '../lib/pragma/version'

Gem::Specification.new do |spec|
  spec.name          = 'pragma-operation'
  spec.version       = Pragma::VERSION
  spec.authors       = ['Alessandro Desantis']
  spec.email         = ['desa.alessandro@gmail.com']

  spec.summary       = 'Business logic encapsulation for your JSON API.'
  spec.homepage      = 'https://github.com/pragmarb/pragma-operation'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-transaction', '~> 0.13.0'
  spec.add_dependency 'zeitwerk', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.23'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'
end
