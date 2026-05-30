# frozen_string_literal: true

module Spree
  class PaymentMethod::CashOnDelivery < PaymentMethod
    # Setting this to false prevents Solidus from automatically trying to capture
    # payment during the checkout confirmation step.
    def auto_capture?
      false
    end

    # Explicitly tell Solidus that this payment method supports manual capture later
    def actions
      %w[capture void credit]
    end

    def can_capture?(payment)
      payment.pending?
    end

    def can_void?(payment)
      payment.pending?
    end

    # Fake gateway operations to make Solidus state-machine happy during checkout
    def authorize(amount_in_cents, source, gateway_options)
      ActiveMerchant::Billing::Response.new(true, "COD Authorized (Pay on Delivery)", {}, authorization: "COD-#{(SecureRandom.random_number * 1000000).to_i}")
    end

    def capture(amount_in_cents, auth_code, gateway_options)
      ActiveMerchant::Billing::Response.new(true, "COD Payment Collected & Captured", {}, {})
    end

    def source_type
      nil
    end
  end
end