Rails.application.routes.draw do
  # 1. Mount the New Admin UI
  # We remove the constraints for now to ensure it loads
  mount SolidusAdmin::Engine, at: '/admin'

  # 2. Mount the Core Engine at the root
  # This handles the API and the Classic Backend (as a fallback)
  mount Spree::Core::Engine, at: '/'

  mount SolidusStripe::Engine, at: '/solidus_stripe'

  # 3. The Storefront
  # This file already contains 'root to: "home#index"' or similar.
  # If you want your store to be at http://localhost:3000/ , 
  # remove the (path: 'store') part.
  scope(path: '/') { draw :storefront }

  get "up" => "rails/health#show", as: :rails_health_check
end