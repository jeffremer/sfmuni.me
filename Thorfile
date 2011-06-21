require 'rspec/core/rake_task'

require 'thor/rake_compat'

class Default < Thor
  include Thor::RakeCompat
  RSpec::Core::RakeTask.new('spec') do |t|
    t.pattern= FileList['spec/*_spec.rb']
  end
end