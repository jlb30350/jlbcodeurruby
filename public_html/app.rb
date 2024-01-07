# app.rb
require 'sinatra/base'

# Include the correct file name: contact_form.rb
require_relative 'contact_form'

class MyApp < Sinatra::Base
  # Configure Sinatra to run on port 5678 (ou tout autre port de votre choix)
  set :port, 5678

  # Configurer le répertoire des vues
  configure do
    set :public_folder, File.join(File.dirname(__FILE__), 'public')
  end

  # Route principale
  get '/' do
    erb :index
  end

  # Autres routes et configurations peuvent être ajoutées ici
  get '/contact' do
    erb :contact
  end
end

# Exécuter l'application si le script est exécuté directement
MyApp.run! if __FILE__ == $0
