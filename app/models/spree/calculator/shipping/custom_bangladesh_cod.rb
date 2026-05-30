# frozen_string_literal: true

module Spree
  class Calculator::Shipping::CustomBangladeshCod < Spree::ShippingCalculator
    preference :base_amount, :decimal, default: 120.0

    def self.description
      "Bangladesh Custom COD (Weight + Order Value)"
    end

    def compute_package(package)
      order = package.order
      
      # 1. 1% COD Commission Fee
      cod_fee = order.item_total * 0.01
      
      # 2. Base shipping cost configured from the Admin panel
      base_shipping = preferred_base_amount
      
      # 3. Calculate total weight of the package (in kg)
      total_weight = package.contents.sum { |item| (item.variant.weight || 0) * item.quantity }

      # 4. Weight fee calculation (Applicable from 2kg+)
      weight_fee = total_weight >= 2 ? (total_weight * 13) : 0

      # 5. Grand Delivery Total
      delivery_cost = cod_fee + base_shipping + weight_fee

      delivery_cost.round(2)
    end
  end
end