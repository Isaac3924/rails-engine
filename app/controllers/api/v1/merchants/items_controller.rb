class Api::V1::Merchants::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :merchant_record_not_found

  def index
    merchant = Merchant.find(params[:merchant_id])
    items = merchant.items
    render json: ItemSerializer.format_items(items)
  end

  private

  def merchant_record_not_found(exception)
    render json: { errors: "Merchant not found with provided ID." }, status: :not_found
  end
end