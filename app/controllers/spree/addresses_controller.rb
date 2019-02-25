if defined?(Spree::Frontend)
  class Spree::AddressesController < Spree::StoreController
    helper Spree::AddressesHelper
    load_and_authorize_resource class: Spree::Address

    def index
      @addresses = spree_current_user.addresses
    end

    def create
      
      @address = spree_current_user.addresses.build(address_params)
      @address.state_name  = params[:address][:state_name]
      
    end

    def show
      redirect_to account_path
    end

    def edit
      session['spree_user_return_to'] = request.env['HTTP_REFERER']
    end

    def new
      @address = Spree::Address.default
    end

    def update
      @address.state_id  = params[:address][:state_id]
      if @address.editable?
        @address_status = @address.update_attributes(address_params)
      else
        new_address = @address.clone
        new_address.attributes = address_params
        new_address.user = @address.user
        @address.update_attribute(:deleted_at, Time.now)
        @address_status = new_address.save
      end
    end

    def destroy

      is_primary = (spree_current_user.shipping_address.try(:id) || spree_current_user.billing_address.try(:id) ) == @address.id 

      if is_primary 
        @address.errors.add(:alert, "Primary Address Can't be deleted");
      else
        @address.destroy
      end
    end

    private
      def address_params
        params[:address].permit(:address,
                                :firstname,
                                :lastname,
                                :address1,
                                :address2,
                                :address3,
                                :city,
                                :zipcode,
                                :country_id,
                                :phone
                               )
      end
  end
end

