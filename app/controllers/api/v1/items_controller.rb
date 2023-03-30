class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :item_record_not_found
  rescue_from ActiveRecord::InvalidForeignKey, with: :item_invalid_merchant

  def index
    items = Item.all
    render json: ItemSerializer.format_items(items)
  end

  def show 
    item = Item.find(params[:id])
    render json: ItemSerializer.format_item(item)
  end

  def create
    item = Item.new(item_params)
    if item.valid?
      item.save
      render json: ItemSerializer.format_item(item), status: :created
    else
      render json: { error: item.errors.full_messages  }, status: :bad_request
    end
  end

  def update
    item = Item.find(params[:id])
    item.update(item_params)
    render json: ItemSerializer.format_item(item)
  end

  def destroy
    Item.find(params[:id]).destroy
  end

  private

  def item_record_not_found(exception)
    render json: { error: "Item not found with ID #{params[:id]}" }, status: :not_found
  end

  def item_invalid_merchant(exception)
    render json: { error: "Item updating with invalid merchant id: #{item_params[:merchant_id]}" }, status: :bad_request
  end

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end