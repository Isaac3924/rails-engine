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

    expect(items.count).to eq(3)

    items.each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(Integer)

      expect(item).to have_key(:name)
      expect(item[:name]).to be_a(String)
    end
  end

  it "can get on item by its id" do
    id = create(:item, merchant_id: @m_id).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item).to have_key(:id)
    expect(item[:id]).to be_an(Integer)

    expect(item).to have_key(:name)
    expect(item[:name]).to be_a(String)
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
    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.name).to eq(item[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.description).to eq(item[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.unit_price).to eq(item[:unit_price])
  end
end