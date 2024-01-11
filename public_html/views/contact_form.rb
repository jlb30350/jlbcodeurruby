# contact_form.rb
require 'sinatra/base'
require 'json'
require 'sendgrid-ruby'
require 'dotenv/load'

module ContactForm
  Dotenv.load

  def is_email(var)
    (var =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i) != nil
  end

  def is_phone(var)
    (var =~ /^\d+$/) != nil
  end

  def verify_input(var)
    var.strip.gsub(/<|>/, '')
  end

  def send_email_with_mail(email_text, email_to)
    `echo "#{email_text}" | mail -s "Message de jlbcodeur !!" #{email_to} --`
  end

  def send_email_with_sendgrid(email_text, email_to)
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    from = SendGrid::Email.new(email: "#{params['firstname']} #{params['name']} <#{params['email']}>")
    to = SendGrid::Email.new(email: email_to)
    subject = 'Sujet de l\'e-mail'
    content = SendGrid::Content.new(type: 'text/plain', value: email_text)
    mail = SendGrid::Mail.new(from, subject, to, content)

    sg.client.mail._('send').post(request_body: mail.to_json)
  end

  class ContactFormApp < Sinatra::Base
    configure do
      set :public_folder, File.join(File.dirname(__FILE__), 'public')
      set :views, File.dirname(__FILE__) + '/views'
    end

    # Route pour gérer les soumissions du formulaire
    post '/submit' do
      array = {
        "firstname" => params['firstname'],
        "name" => params['name'],
        "email" => params['email'],
        "phone" => params['phone'],
        "message" => params['message'],
        "firstnameError" => "",
        "nameError" => "",
        "emailError" => "",
        "phoneError" => "",
        "messageError" => "",
        "isSuccess" => false
      }

      email_to = "jeanlucbonneville@gmail.com"

      %w[firstname name email phone message].each do |field|
        if params[field].to_s.strip.empty?
          array["#{field}Error"] = "Le champ #{field.capitalize} est requis."
          array["isSuccess"] = false
        else
          array[field] = verify_input(params[field])
        end
      end

      if array["isSuccess"]
        email_text = "#{array['firstname'].capitalize}: #{array['firstname']}\n"
        email_text += "#{array['name'].capitalize}: #{array['name']}\n"
        email_text += "#{array['email'].capitalize}: #{array['email']}\n"
        email_text += "#{array['phone'].capitalize}: #{array['phone']}\n"
        email_text += "#{array['message'].capitalize}: #{array['message']}\n"

        send_email_with_mail(email_text, email_to)
        send_email_with_sendgrid(email_text, email_to)

        # Si la soumission est via AJAX, renvoyer la réponse au format JSON
        if request.xhr?
          content_type :json
          return array.to_json
        end

        # Rediriger vers la page de confirmation
        redirect '/confirmation'
      else
        # Si la validation échoue, afficher la page d'accueil avec les erreurs
        erb :index, locals: { errors: array }
      end
    end

    # Route pour la page d'accueil
    get '/' do
      erb :index, locals: { errors: {} }
    end

    # Page de confirmation
    get '/confirmation' do
      erb :confirmation
    end

    run! if $PROGRAM_NAME == __FILE__ && !defined?(MyApp)
  end
end
