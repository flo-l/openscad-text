Gem::Specification.new do |s|
  s.name        = 'openscad-text'
  s.version     = '1.0.2'
  s.date        = '2014-06-25'
  s.summary     = "Create openscad texts easily"
  s.description = "A text-generator for Openscad"
  s.authors     = ["Florian Lackner"]
  s.files       = Dir["lib/**/*.rb"]
  #s.homepage   = 'https://github.com/flo-l/openscad-text'
  s.license     = 'MIT'

  s.add_runtime_dependency 'rmagick', '~> 2'
end
