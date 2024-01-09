# app.rb
require 'sinatra/base'
require 'dotenv/load'

# Include the correct file name: contact_form.rb
require_relative 'contact_form'

class MyApp < Sinatra::Base
  # Configure Sinatra to run on port 4567 (or any other port of your choice)
  set :port, 4567

  # Configure the views directory
  configure do
    set :public_folder, File.join(File.dirname(__FILE__), 'public')
    set :views, File.dirname(__FILE__) + '/views'
  end

  # Main route
  get '/' do
    erb :index
  end

  # Other routes and configurations can be added here
  get '/contact' do
    erb :contact
  end

  # Show that the contact form is an extension of the main application
  register ContactForm

  # Use the route defined in the ContactForm module
  post '/submit' do
    post_submit
  end

  run! if app_file == $0
end
