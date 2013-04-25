require 'rubygems'
require 'bundler'
Bundler.require

require 'cinch/test'

require 'minitest/spec'
require 'wrong/adapters/minitest'

Wrong.config[:color] = true

require 'rr/adapters/minitest'
class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end

spec_dir = File.dirname(__FILE__)

Dir[File.expand_path('support/**/*.rb', spec_dir)].each do |f|
  require f
end
