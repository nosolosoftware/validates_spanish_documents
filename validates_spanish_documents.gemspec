lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'validates_spanish_documents'

Gem::Specification.new do |spec|
  spec.name          = 'validates_spanish_documents'
  spec.version       = ValidatesSpanishDocuments::VERSION
  spec.authors       = ['Rafael Jurado']
  spec.email         = ['rjurado@nosolosoftware.es']
  spec.summary       = 'Common validations.'
  spec.description   = 'Add common validations.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
