# frozen_string_literal: true

module Spree
  class PaymentMethod::CashOnDelivery < PaymentMethod
    # Ensures it doesn't try to capture funds automatically during checkout
    def auto_capture?
      false
    end

    # Explicitly list actions allowed on a pending COD payment line
    def actions
      %w[capture void]
    end

    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def can_void?(payment)
      payment.pending? || payment.checkout?
    end

    # No database source model required for offline cash collection
    def payment_source_class
      nil
    end

    def source_required?
      false
    end

    # Core change: Tell Solidus to transition this from 'checkout' to 'pending'
    def purchase(amount_in_cents, source, gateway_options)
      authorize(amount_in_cents, source, gateway_options)
    end

    def authorize(amount_in_cents, source, gateway_options)
      ActiveMerchant::Billing::Response.new(
        true,
        "COD Authorized (Awaiting Doorstep Handover)",
        {},
        authorization: "COD-#{(SecureRandom.random_number * 1000000).to_i}"
      )
    end

    def capture(amount_in_cents, auth_code, gateway_options)
      ActiveMerchant::Billing::Response.new(
        true,
        "COD Payment Collected From Courier Ledger",
        {},
        {}
      )
    end

    def source_type
      nil
    end
  end
end