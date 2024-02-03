# frozen_string_literal: true

# Class used to send mails using mailjet
class Mailer
  SEND_MAIL_URL = 'https://api.mailjet.com/v3.1/send'

  def send(from:, to:, subject:, content:)
    HTTParty.post(
      SEND_MAIL_URL,
      basic_auth: auth_info,
      headers: ResponseHelper::Header.json_content_type,
      body: payload(from:, to:, subject:, content:)
    )
  end

  private

  def payload(from:, to:, subject:, content:)
    {
      Messages: [
        {
          From: {
            Email: from,
            Name: 'Arival Admin'
          },
          To: [
            {
              Email: to,
              Name: to
            }
          ],
          Subject: subject,
          TextPart: content
        }
      ]
    }
  end

  def auth_info
    mailjet_config = App.config.mailjet
    { username: mailjet_config.api_key, password: mailjet_config.secret_key }
  end
end
