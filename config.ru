require 'sprockets'
require 'sprockets-sass'
require 'sprockets-helpers'
require 'skim'

map '/compiled' do
  # Setup Sprockets Asset Packaging
  environment = Sprockets::Environment.new
  environment.append_path 'src'

  # Define Asset Path Helper for SCSS
  Sprockets::Helpers.configure do |config|
    config.environment = environment
    config.prefix = '/compiled'
    config.digest = false
  end

  # Serve Assets
  run environment
end

# Serve static HTML
map '/' do
  run Proc.new {|env|
    request = Rack::Request.new(env)
    request.path_info = "index.html" if request.path_info == "/"
    Rack::Directory.new(Dir.pwd).call(env)
  }
end
