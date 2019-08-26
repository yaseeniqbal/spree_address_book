Spree::Core::Engine.add_routes do
  resources :addresses

  get '/shipping_calculator', to: 'addresses#shipping_calculator', as: "shipping_calculator"

  if Rails.env.test?
    put '/cart', :to => 'orders#update', :as => :put_cart
  end
end