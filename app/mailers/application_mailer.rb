class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('EMAIL_FROM_ADDRESS', 'no-reply@example.com')
  layout 'mailer'
end
