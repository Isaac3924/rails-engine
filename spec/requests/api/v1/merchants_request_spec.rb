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
      expect(merchant[:id]).to be_a(String)

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

  it "can find a number of merchants based on a search parameter" do
    merch1 = Merchant.create(name: "planners")
    merch2 = Merchant.create(name: "Planes")
    merch3 = Merchant.create(name: "arcade")
    merch4 = Merchant.create(name: "whateva")

    get "/api/v1/merchants/find_all?name=plan"

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants[:data].count).to eq(2)
    expect(merchants[:data][0]).to have_key(:id)
    expect(merchants[:data][0][:id]).to be_a(String)
    expect(merchants[:data][1]).to have_key(:id)
    expect(merchants[:data][1][:id]).to be_a(String)

    expect(merchants[:data][0][:attributes]).to have_key(:name)
    expect(merchants[:data][0][:attributes][:name]).to be_a(String)
    expect(merchants[:data][0][:attributes][:name]).to eq("Planes")
    expect(merchants[:data][1][:attributes]).to have_key(:name)
    expect(merchants[:data][1][:attributes][:name]).to be_a(String)
    expect(merchants[:data][1][:attributes][:name]).to eq("planners")
  end

  it "will return all merchants if there is no parameter" do
    merch1 = Merchant.create(name: "planners")
    merch2 = Merchant.create(name: "Planes")
    merch3 = Merchant.create(name: "arcade")
    merch4 = Merchant.create(name: "whateva")

    get "/api/v1/merchants/find_all?name="
    
    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants[:data].count).to eq(4)
  end
end