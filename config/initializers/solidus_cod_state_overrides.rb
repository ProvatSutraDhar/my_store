# frozen_string_literal: true

Rails.application.configure do
  config.to_prepare do
    Spree::Order.class_eval do
      def paid_or_order_allows_cod_shipping?
        return true if payments.valid.any? { |p| p.payment_method.is_a?(Spree::PaymentMethod::CashOnDelivery) }
        paid? || billed_total == total
      end
    end

    Spree::Shipment.class_eval do
      # 1. Add custom state-checking methods for your dashboard/reports
      def partial_delivery?
        # A shipment is a partial delivery if it's shipped but has active returns or modifications
        shipped? && inventory_units.any?(&:returned?)
      end

      def delivery_failed?
        # Full rejection by customer at the doorstep
        shipped? && inventory_units.all?(&:returned?)
      end

      # 2. Update the state machine evaluator
      def determine_state(order)
        return 'pending' if order.canceled?
        return 'shipped' if shipped?
        
        if order.payments.valid.any? { |p| p.payment_method.is_a?(Spree::PaymentMethod::CashOnDelivery) }
          return 'ready' unless shipped?
        end

        order.can_ship? ? 'ready' : 'pending'
      end
    end
  end
end