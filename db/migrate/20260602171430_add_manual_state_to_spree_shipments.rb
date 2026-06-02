class AddManualStateToSpreeShipments < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_shipments, :manual_state, :string
  end
end
