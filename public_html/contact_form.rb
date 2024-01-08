#contact
require 'sinatra'
require 'json'

def is_email(var)
  (var =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i) != nil
end

def is_phone(var)
  (var =~ /^\d+$/) != nil
end

def verify_input(var)
  var = var.strip
  var = var.gsub(/<|>/, '')
  var
end


require 'pony'
require 'sendgrid-ruby'


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

  params.each do |key, value|
    array[key] = verify_input(value)
  end

  array["isSuccess"] = true
  email_text = ""

  if array["firstname"].empty?
    array["firstnameError"] = "Je veux connaitre ton prénom !"
    array["isSuccess"] = false
  else
    email_text += "Firstname: #{array["firstname"]}\n"
  end

  if array["name"].empty?
    array["nameError"] = "Et oui je veux tout savoir. Même ton nom !"
    array["isSuccess"] = false
  else
    email_text += "Name: #{array['name']}\n"
  end

  unless is_email(array["email"])
    array["emailError"] = "T'essaies de me rouler ? C'est pas un email ça  !"
    array["isSuccess"] = false
  else
    email_text += "Email: #{array['email']}\n"
  end

  unless is_phone(array["phone"])
    array["phoneError"] = "Que des chiffres et des espaces, stp..."
    array["isSuccess"] = false
  else
    email_text += "Phone: #{array['phone']}\n"
  end

  if array["message"].empty?
    array["messageError"] = "Qu'est-ce que tu veux me dire ?"
    array["isSuccess"] = false
  else
    email_text += "Message: #{array['message']}\n"
  end

  if array["isSuccess"]
    headers = "From: #{array['firstname']} #{array['name']} <#{array['email']}>\r\nReply-To: #{array['email']}"
    `echo "#{email_text}" | mail -s "Message de jlbcodeur !!" #{email_to} --`
  end

  if array["isSuccess"]
    # Configuration pour l'envoi d'e-mails avec SendGrid
    sg = SendGrid::API.new(api_key: 'SG.fTKIkrQbSzm9tPBozE5fJw.hhpthKRXJngdD6WYl8SmPG2p0iVcPKD8DVzFebMRI ')
    from = SendGrid::Email.new(email: "#{array['firstname']} #{array['name']} <#{array['email']}>")
    to = SendGrid::Email.new(email: email_to)
    subject = 'Sujet de l\'e-mail'
    content = SendGrid::Content.new(type: 'text/plain', value: email_text)
    mail = SendGrid::Mail.new(from, subject, to, content)

    # Envoi de l'e-mail
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end

  content_type :json
  array.to_json
  end

