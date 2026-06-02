class ShipmentOverridesController < ApplicationController
  before_action :authenticate_spree_user! # Adjust based on your admin auth setup

  def force_state
    # Find the shipment by its friendly code (e.g., H31021302488)
    shipment = Spree::Shipment.find_by!(number: params[:id])
    
    # FIX: Use update_column to change the record without triggering state-machine validation crashes
    shipment.update_column(:manual_state, params[:manual_state])
    
    # Tell the updater engine to recalculate everything and persist it safely
    shipment.order.updater.update

    flash[:success] = "Shipment status updated successfully!"
    redirect_back fallback_location: "/admin"
  end
end