# contact.rb
require 'sinatra'
require 'json'
require 'sendgrid-ruby'
require 'dotenv/load'

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
  sg = SendGrid::API.new(api_key: ENV['SG.fTKIkrQbSzm9tPBozE5fJw.hhpthKRXJngdD6WYl8SmPG2p0iVcPKD8DVzFebMRI'])
  from = SendGrid::Email.new(email: "#{params['firstname']} #{params['name']} <#{params['email']}>")
  to = SendGrid::Email.new(email: email_to)
  subject = 'Sujet de l\'e-mail'
  content = SendGrid::Content.new(type: 'text/plain', value: email_text)
  mail = SendGrid::Mail.new(from, subject, to, content)

  sg.client.mail._('send').post(request_body: mail.to_json)
end

post '/submit' do
  array = {
    "firstname" => " ",
    "name" => " ",
    "email" => " ",
    "phone" => " ",
    "message" => " ",
    "firstnameError" => " ",
    "nameError" => " ",
    "emailError" => " ",
    "phoneError" => " ",
    "messageError" => " ",
    "isSuccess" => false
  }

  email_to = "jeanlucbonneville@gmail.com"

  params.each { |key, value| array[key] = verify_input(value) }

  array["isSuccess"] = true
  email_text = ""

  %w[firstame name email phone message].each do |field|
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
end
