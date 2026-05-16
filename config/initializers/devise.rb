# frozen_string_literal: true

Devise.secret_key = '940a2a058c080af02413b69e6cb352bd51cca28f1a82bdafcbed2d666c9e018413530ccd40470b9ea37daff270d65bf1a5c480f10276a3a6a92e8951d9945f73'
Devise.email_regexp = Spree::Config[:default_email_regexp]
Devise.setup do |config|
  config.parent_controller = 'StoreDeviseController'
  config.mailer = 'UserMailer'
end
