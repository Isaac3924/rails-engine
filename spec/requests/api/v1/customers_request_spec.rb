require 'rails_helper'

describe "Customers API" do
  it "sends a list of customers" do
    create_list(:customer, 3)

    get '/api/v1/customers'
    require 'pry'; binding.pry

    expect(response).to be_successful

    customers = JSON.parse(response.body, symbolize_names: true)

    expect(customers.count).to eq(3)

    customers.each do |customer|
      expect(customer)
    end
  end
end