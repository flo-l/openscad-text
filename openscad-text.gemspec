Gem::Specification.new do |s|
  s.name        = 'openscad-text'
  s.version     = '0.1.0'
  s.date        = '2014-06-17'
  s.summary     = "Create openscad texts easily"
  s.description = "A text-generator for Openscad"
  s.authors     = ["Florian Lackner"]
  s.files       = Dir["lib/**/*.rb"]
  #s.homepage   = 'http://rubygems.org/gems/hola'
  s.license     = 'MIT'

  s.add_runtime_dependency 'rmagick', '~> 2'
end
