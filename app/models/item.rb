class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true
  validates :merchant_id, presence: true

  def check_invoices
    self.invoice_items.each do |invoice_item|
      invoice = invoice_item.invoice
      if invoice.items.where.not(id: self.id).empty?
        invoice_item.destroy
        invoice.destroy
      else  
        invoice_item.destroy
      end
    end
  end

  def self.find_one_name(name)
    self.where('LOWER(name) LIKE ?', "%#{name.downcase}%").order(:name).first
  end
end