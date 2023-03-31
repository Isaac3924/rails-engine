class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :item_record_not_found

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

  def find
    name = params[:name]
    min_price = params[:min_price]
    max_price = params[:max_price]

    if name.present? && (min_price.present? || max_price.present?)
      render json: { errors: "Your search included both a name and price parameter.", data: {} }, status: :bad_request
    elsif name.present?
      item = Item.find_one_name(name)
      if item.present?
        render json: ItemSerializer.format_item(item)
      else
        render json: { errors: "Your search '#{name}', contained 0 results", data: {} }, status: :not_found
      end
    elsif min_price.present? && min_price.to_f < 0
      render json: { errors: "min_price must be greater than or equal to 0", data: {} }, status: :bad_request
    elsif max_price.present? && max_price.to_f < 0
      render json: { errors: "max_price must be greater than or equal to 0", data: {} }, status: :bad_request
    elsif min_price.present? && max_price.present? && min_price.to_f > max_price.to_f
      render json: { errors: "min_price must be less than or equal to max_price", data: {} }, status: :bad_request
    elsif min_price.present? || max_price.present?
      min_price = min_price.present? ? min_price.to_f : 0
      max_price = max_price.present? ? max_price.to_f : Float::INFINITY
      items = Item.find_prices(min_price, max_price)
      if items.any?
        render json: ItemSerializer.format_item(items.first)
      else
        render json: { errors: "No items found", data: {} }, status: :not_found
      end
    else
      render json: { errors: 'Incorrect parameters input' }, status: :bad_request
    end
  end

  private

  def item_record_not_found(exception)
    render json: { error: "Item not found with ID #{params[:id]}" }, status: :not_found
  end

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id).reject { |k, v| v.blank? }
  end
end