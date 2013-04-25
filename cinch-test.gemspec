require './lib/cinch/test/version'

Gem::Specification.new do |s|
  s.name = "cinch-test"
  s.version = Cinch::Test.version
  s.authors = ["Jay Adkisson"]
  s.email = ["jay@jayferd.us"]
  s.summary = "utility methods for testing Cinch bots"
  s.description = <<-desc.strip.gsub(/\s+/, ' ')
    A collection of utility methods for testing Cinch bots
  desc
  s.homepage = "http://github.com/jayferd/cinch-test"
  s.rubyforge_project = "cinch-test"
  s.files = Dir['Gemfile', 'cinch-test.gemspec', 'lib/**/*.rb']

  s.add_dependency 'cinch'
end
