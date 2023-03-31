class Api::V1::Items::MerchantController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :merchant_record_not_found

  def index
    item = Item.find(params[:item_id])
    merchant = item.merchant
    render json: MerchantSerializer.format_merchant(merchant)
  end

  private

  def merchant_record_not_found(exception)
    render json: { error: "Merchant not found with provided ID." }, status: :not_found
  end
end