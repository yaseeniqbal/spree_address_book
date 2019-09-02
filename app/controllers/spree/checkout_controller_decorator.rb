if defined?(Spree::Frontend)
  Spree::CheckoutController.class_eval do
    helper Spree::AddressesHelper

    after_action :normalize_addresses, :only => :update
    before_action :set_addresses, :only => :update


    protected

    def set_addresses

      return unless params[:order] && params[:state] == "address"

      if params[:order][:ship_address_id].to_i > 0
        params[:order].delete(:ship_address_attributes)
        Spree::Address.find(params[:order][:ship_address_id]).user_id != spree_current_user.id && raise("Frontend address forging")
      else
        params[:order].delete(:ship_address_id)
      end

      if params[:order][:bill_address_id].to_i > 0
        params[:order].delete(:bill_address_attributes)
        Spree::Address.find(params[:order][:bill_address_id]).user_id != spree_current_user.id && raise("Frontend address forging")
      else
        params[:order].delete(:bill_address_id)
      end

    end

    def normalize_addresses

      return unless params[:state] == "address" && @order.bill_address_id && @order.ship_address_id
      # ensure that there is no validation errors and addresses were saved
      return unless @order.bill_address and @order.ship_address

      @order.bill_address_id  = params[:order].present? ? params[:order][:bill_address_id].to_i : @order.bill_address.id
      @order.ship_address_id  = params[:order].present? ? params[:order][:ship_address_id].to_i : @order.ship_address.id
      use_shipping             = params[:order].present? ? params[:order][:use_shipping] : ""

      bill_address            = @order.bill_address
      ship_address            = @order.ship_address

      if  (use_shipping.present? || use_shipping.to_i == 1)
        @order.update_column(:bill_address_id, ship_address.id)
        @order.update_column(:ship_address_id, ship_address.id)
      else
        bill_address.update_attribute(:user_id, spree_current_user.try(:id))
      end

      ship_address.update_attribute(:user_id, spree_current_user.try(:id))

    end
  end
end
