# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require_relative './lib/generator/generator.rb'

RSpec::Core::RakeTask.new(:spec)

desc 'Generate code from JSON API spec'
task :generate do
  Elastic::Generator.generate
end
