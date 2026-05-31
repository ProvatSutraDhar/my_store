# frozen_string_literal: true

module Spree
  class Calculator::Shipping::CustomBangladeshCod < Spree::ShippingCalculator
    # This preference allows you to type 60 or 120 directly in your Solidus Admin panel!
    preference :base_amount, :decimal, default: 120.0

    def self.description
      "Bangladesh Custom COD (Weight + Order Value)"
    end

    def compute_package(package)
      return 0.0 if package.nil? || package.contents.blank?

      order = package.order
      
      # 1. 1% COD Commission Fee
      item_total_amount = order&.item_total.to_f
      cod_fee = item_total_amount * 0.01
      
      # 2. Dynamic Base Shipping Cost 
      # This pulls whatever number (60 or 120) you typed inside that specific Shipping Method Admin panel
      base_shipping = preferred_base_amount.to_f
      
      # 3. Calculate total weight of the package (in kg)
      total_weight = package.contents.sum do |item| 
        variant_weight = item.variant.weight.present? ? item.variant.weight.to_f : 0.0
        variant_weight * item.quantity
      end

      # 4. Weight fee calculation (Applicable from 2kg+)
      weight_fee = total_weight >= 2.0 ? (total_weight * 13.0) : 0.0

      # 5. Grand Delivery Total
      delivery_cost = cod_fee + base_shipping + weight_fee

      delivery_cost.round(2)
    rescue StandardError => e
      Rails.logger.error "CustomBangladeshCod Error: #{e.message}"
      preferred_base_amount.to_f.round(2)
    end
  end
end