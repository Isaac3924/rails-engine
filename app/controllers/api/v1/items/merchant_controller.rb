class Api::V1::Items::MerchantController < ApplicationController
  def index
    item = Item.find(params[:item_id])
    merchant = item.merchant
    render json: MerchantSerializer.format_merchant(merchant)
  end
end