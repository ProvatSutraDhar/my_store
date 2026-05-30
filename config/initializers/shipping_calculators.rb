# frozen_string_literal: true

Rails.application.configure do
  config.after_initialize do
    # Added .rb here so Ruby knows exactly what file to read
    require_dependency Rails.root.join("app/models/spree/calculator/shipping/custom_bangladesh_cod.rb")

    config.spree.calculators.shipping_methods << "Spree::Calculator::Shipping::CustomBangladeshCod"
  end
end