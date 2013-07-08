require 'rubygems'

# Set up gems listed in the Gemfile.
puts ENV['BUNDLE_GEMFILE']
puts File.expand_path('../../Gemfile', __FILE__)
puts File.expand_path('../../Gemfile')
puts __FILE__
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
