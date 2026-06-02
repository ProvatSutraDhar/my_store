# frozen_string_literal: true

Rails.application.configure do
  config.to_prepare do
    Spree::PermittedAttributes.shipment_attributes << :manual_state
  end
end