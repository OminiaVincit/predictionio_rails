class Business < ActiveRecord::Base
  has_many :reviews
  serialize :categories
  
  geocoded_by :full_address

  # the callback to set longitude and latitude
  after_validation :geocode

  # the full_address method
  #def full_address
  #  "#{full_address}"
  #end
end
