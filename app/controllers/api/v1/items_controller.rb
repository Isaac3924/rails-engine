class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :item_record_not_found

  def index
    render json: Item.all
  end

  def show 
    render json: Item.find(params[:id])
  end

  def create
    render json: Item.create(item_params)
  end

  private

  def item_record_not_found(exception)
    render json: { error: "Item not found with ID #{params[:id]}" }, status: :not_found
  end

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end