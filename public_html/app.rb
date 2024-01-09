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

  post '/submit' do
    begin
      # Your existing code here
      array = {
        # ... (existing array initialization)
      }

      email_to = "jeanlucbonneville@gmail.com"

      # Validate and process the form data
      params.each { |key, value| array[key] = verify_input(value) }

      array["isSuccess"] = true
      email_text = ""

      %w[firstname name email phone message].each do |field|
        if array[field].empty?
          array["#{field}Error"] = "Le champ #{field.capitalize} est requis."
          array["isSuccess"] = false
        else
          email_text += "#{field.capitalize}: #{array[field]}\n"
        end
      end

      send_email_with_mail(email_text, email_to) if array["isSuccess"]
      send_email_with_sendgrid(email_text, email_to) if array["isSuccess"]

      content_type :json
      array.to_json
    rescue => e
      puts "Erreur rencontrée: #{e.message}"
      # Handle the error as needed, you can return a custom error message or page
    end
  end

  run! if app_file == $0
end
