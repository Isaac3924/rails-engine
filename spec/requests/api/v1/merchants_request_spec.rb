require 'rails_helper'

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(Integer)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it "can get a merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to be_a(String)

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to be_a(String)
  end

  it "raises an error when it cannot find a merchant by id" do
    get "/api/v1/merchants/101"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to_not be_successful

    expect(merchant).to_not have_key(:id)

    expect(merchant).to_not have_key(:name)

    expect(merchant).to be_a(Hash)
    expect(merchant).to eq({:error=>"Merchant not found with ID 101"})
  end

  it "can return all items from given merchant ID" do
    merch1 = create(:merchant)
    merch2 = create(:merchant)
    item1 = create(:item, merchant_id: merch1.id)
    item2 = create(:item, merchant_id: merch1.id)
    item3 = create(:item, merchant_id: merch1.id)
    item4 = create(:item, merchant_id: merch2.id)

    get "/api/v1/merchants/#{merch1.id}/items"

    merchant_items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(Item.all.count).to eq(4)
    expect(merchant_items[:data]).to be_a(Array)
    expect(merchant_items[:data].count).to eq(3)
    expect(merchant_items[:data][0][:attributes]).to have_key(:name)
    expect(merchant_items[:data][0][:attributes][:name]).to be_a(String)
  end

  it "can return an error if there is no merchant id that exists" do
    merch1 = create(:merchant)
    merch2 = create(:merchant)
    item1 = create(:item, merchant_id: merch1.id)
    item2 = create(:item, merchant_id: merch1.id)
    item3 = create(:item, merchant_id: merch1.id)
    item4 = create(:item, merchant_id: merch2.id)

    get "/api/v1/merchants/12345/items"

    merchant_items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to_not be_successful
    expect(response).to have_http_status(404)
    expect(merchant_items).to eq({:errors=>"Merchant not found with provided ID."})
  end
end