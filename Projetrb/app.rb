# app.rb
require 'sinatra/base'
require 'dotenv'
require_relative 'contact_form.rb'

# Charge les variables d'environnement à partir du fichier .env
Dotenv.load

class MyApp < Sinatra::Base
  # Configure Sinatra to run on port 3000
  set :port, ENV['PORT'] || 3000


  # Configure the views directory
  configure do
    set :public_folder, File.join(File.dirname(__FILE__), 'public')
    set :views, File.dirname(__FILE__) + '/views'
  end

  # Include the ContactForm module
  include ContactForm

  # Main route
  get '/' do
    erb :index
  end

  # Other routes and configurations can be added here
  get '/contact' do
    erb :contact
  end

  # Use the route defined in the ContactForm module
  post '/submit' do
    register_routes
  end

  get '/show-routes' do
    routes = settings.routes['GET'].map { |route| route[0].to_s }
    routes.join('<br>')
  end

  error do
    'Une erreur est survenue'
  end

  # run! if app_file == $0
end

