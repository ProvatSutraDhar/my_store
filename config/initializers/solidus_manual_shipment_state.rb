# frozen_string_literal: true

Rails.application.configure do
  config.to_prepare do
    # 1. Individual Shipment Overrides
    Spree::Shipment.class_eval do
      old_determine_state = instance_method(:determine_state)

      define_method(:determine_state) do |order|
        return manual_state if manual_state.present?
        old_determine_state.bind(self).call(order)
      end

      def state
        manual_state.present? ? manual_state : read_attribute(:state)
      end
    end

    # 2. Global Order Overrides (Updates right-hand menu badge calculations)
    Spree::Order.class_eval do
      def shipment_state
        if shipments.any? { |s| s.manual_state.present? }
          states = shipments.map { |s| s.manual_state.present? ? s.manual_state : s.read_attribute(:state) }
          
          if states.include?('backorder')
            'backorder'
          elsif states.all?('shipped')
            'shipped'
          elsif states.all?('shipping') # FIX: Prioritize complete shipping status arrays higher
            'shipping'
          elsif states.any?('shipped') || states.any?('shipping')
            'partial'
          else
            'pending'
          end
        else
          read_attribute(:shipment_state)
        end
      end
    end

    # 3. Order Updater Sync Hooks
    Spree::OrderUpdater.class_eval do
      def update_shipment_state
        if order.shipments.any? { |s| s.manual_state.present? }
          states = order.shipments.map { |s| s.manual_state.present? ? s.manual_state : s.read_attribute(:state) }
          
          if states.include?('backorder')
            order.shipment_state = 'backorder'
          elsif states.all?('shipped')
            order.shipment_state = 'shipped'
          elsif states.all?('shipping') # FIX: Prioritize complete shipping status arrays higher
            order.shipment_state = 'shipping'
          elsif states.any?('shipped') || states.any?('shipping')
            order.shipment_state = 'partial'
          else
            order.shipment_state = 'pending'
          end
          return order.shipment_state
        end

        # Core fallback tracking code
        if order.backordered?
          order.shipment_state = 'backorder'
        else
          has_ready = order.shipments.any? { |s| s.state == 'ready' || s.state == 'shipping' }
          has_pending = order.shipments.any?(&:pending?)
          has_shipped = order.shipments.any?(&:shipped?)

          if has_ready && has_pending
            order.shipment_state = 'partial'
          elsif has_ready
            order.shipment_state = 'shipping'
          elsif has_pending
            order.shipment_state = 'pending'
          elsif has_shipped
            order.shipment_state = 'shipped'
          end
        end
        order.shipment_state
      end
    end
  end
end