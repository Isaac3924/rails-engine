class Merchant < ApplicationRecord
  has_many :items

  def self.find_all_names(name)
    self.where('lower(name) LIKE ?', "%#{name.downcase}%").order('name ASC').limit(20)
  end
end
