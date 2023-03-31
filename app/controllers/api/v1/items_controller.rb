class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :item_record_not_found
  rescue_from ActiveRecord::InvalidForeignKey, with: :item_invalid_merchant

  def index
    require 'pry'; binding.pry
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
    merchant_ids = Merchant.all.map do |merchant|
      merchant.id
    end

    if item_params[:merchant_id] && merchant_ids.exclude?(item_params[:merchant_id])
      render json: { error: "Item updating with invalid merchant id: #{item_params[:merchant_id]}" }, status: :bad_request
    elsif item_params[:name] && item_params[:name].class != String
      render json: { error: "Item updating with incorrect data type for name: #{item_params[:name].class}" }, status: :bad_request
    elsif item_params[:description] && item_params[:description].class != String
      render json: { error: "Item updating with incorrect data type for description: #{item_params[:description].class}" }, status: :bad_request
    elsif item_params[:unit_price] && item_params[:unit_price].class != Float
      render json: { error: "Item updating with incorrct data type for unit price: #{item_params[:unit_price].class}" }, status: :bad_request
    elsif item_params[:merchant_id] && item_params[:merchant_id].class != Integer
      render json: { error: "Item updating with incorrct data type for merchant id: #{item_params[:merchant_id].class}" }, status: :bad_request
    else
      item.update(item_params)
      render json: ItemSerializer.format_item(item)
    end
  end

  def destroy
    item = Item.find(params[:id])
    item.check_invoices
    item.destroy
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