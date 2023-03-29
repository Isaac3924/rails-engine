class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :merchant_record_not_found

  def index
    merchants = Merchant.all
    render json: MerchantSerializer.format_merchants(merchants)
  end

  def show 
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.format_merchant(merchant)
  end

  private

  def merchant_record_not_found(exception)
    render json: { error: "Merchant not found with ID #{params[:id]}" }, status: :not_found
  end
end