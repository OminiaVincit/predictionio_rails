class User < ActiveRecord::Base
  has_many :reviews
  validates :yelp_user_id, :presence => true, :uniqueness => true, :length => { :in => 3..40 }
end
