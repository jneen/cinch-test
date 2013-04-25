require 'pathname'

task :spec do
  spec_files = FileList.new(ENV['files'] || './spec/**/*_spec.rb')
  switch_spec_files = spec_files.map { |x| "-r#{x}" }.join(' ')
  sh "ruby -I./lib -r ./spec/spec_helper #{switch_spec_files} -e Minitest::Unit.autorun"
end

task :default => :spec

Dir.glob(Pathname.new(__FILE__).dirname.join('tasks/*.rake')).each do |f|
  load f
end
