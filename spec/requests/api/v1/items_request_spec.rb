require 'rails_helper'

describe "Items API" do
  before do
    @m_id = create(:merchant).id
  end

  it "sends a list of items" do
    create_list(:item, 3, merchant_id: @m_id)

    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(3)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)
      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)
      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_an(Integer)
    end
  end

  it "can get an item by its id" do
    id = create(:item, merchant_id: @m_id).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to be_a(String)
    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to be_a(String)
    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to be_a(Float)
    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to be_an(Integer)
  end

  it "raises an error when it cannot find a item by id" do
    get "/api/v1/items/101"

    item = JSON.parse(response.body, symbolize_names: true)
    
    expect(response).to_not be_successful

    expect(item).to_not have_key(:id)

    expect(item).to_not have_key(:name)

    expect(item).to be_a(Hash)
    expect(item).to eq({:error=>"Item not found with ID 101"})
  end

  it "can create a new item" do
    item_params = ({
      name: 'The Thing',
      description: 'It sure does do a thing',
      unit_price: 2.5,
      merchant_id: @m_id
    })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    item = JSON.parse(response.body, symbolize_names: true)
    created_item = Item.last

    expect(response).to be_successful
    expect(response).to have_http_status(201)
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.name).to eq(item[:data][:attributes][:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.description).to eq(item[:data][:attributes][:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.unit_price).to eq(item[:data][:attributes][:unit_price])
  end

  it "returns an error when any of the attributes are missing in create" do
    item_params = ({
      description: 'It sure does do a thing',
      unit_price: 2.5,
      merchant_id: @m_id
    })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    item = JSON.parse(response.body, symbolize_names: true)
    created_item = Item.last
    
    expect(response).to_not be_successful
    expect(response).to have_http_status(400)
  end

  it "can destroy an item" do
    item = create(:item, merchant_id: @m_id)

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(response).to have_http_status(204)
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can destroy an invoice when it destroys an item that is the singular item on the invoice" do
    item = create(:item, merchant_id: @m_id)
    invoice = Invoice.create() 
    InvoiceItem.create(invoice_id: invoice.id, item_id: item.id)

    expect(Item.count).to eq(1)
    expect(Invoice.count).to eq(1)
    expect(InvoiceItem.count).to eq(1)
    
    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(response).to have_http_status(204)
    expect(Item.count).to eq(0)
    expect(InvoiceItem.count).to eq(0)
    expect(Invoice.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "will not destroy an invoice when it destroys an item that is not the singular item on the invoice" do
    item1 = create(:item, merchant_id: @m_id)
    item2 = create(:item, merchant_id: @m_id)
    invoice = Invoice.create() 
    InvoiceItem.create(invoice_id: invoice.id, item_id: item1.id)
    InvoiceItem.create(invoice_id: invoice.id, item_id: item2.id)

    expect(Item.count).to eq(2)
    expect(Invoice.count).to eq(1)
    expect(InvoiceItem.count).to eq(2)
    
    delete "/api/v1/items/#{item1.id}"

    expect(response).to be_successful
    expect(response).to have_http_status(204)
    expect(Item.count).to eq(1)
    expect(InvoiceItem.count).to eq(1)
    expect(Invoice.count).to eq(1)
    expect{Item.find(item1.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can update an existing item" do
    item = create(:item, merchant_id: @m_id)
    previous_name = Item.last.name
    item_params = {name: "Burning Wheel"}
    headers = {"CONTENT_TYPE" => "application/json"}
    
    patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: item.id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("Burning Wheel")
  end

  it "returns error if updating the merchant id to one that doesn't exist" do
    item = create(:item, merchant_id: @m_id)
    previous_name = Item.last.name
    item_params = {merchant_id: 1111111111}
    headers = {"CONTENT_TYPE" => "application/json"}
    
    put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: item.id)

    expect(response).to_not be_successful
    expect(response).to have_http_status(400)
  end

  it "returns error if updating an item attribute to an unsupported data type" do
    item = create(:item, merchant_id: @m_id)
    previous_name = Item.last.name
    item_params = {description: 13}
    headers = {"CONTENT_TYPE" => "application/json"}
    
    put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: item.id)

    expect(response).to_not be_successful
    expect(response).to have_http_status(400)
  end
end