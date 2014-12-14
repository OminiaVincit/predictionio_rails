class UsersController < ApplicationController

  def create

  end

  def index
    catego = "restaurant"
    @users = User.order('reviews_count DESC').limit(20)
    @businesses = Business.near('Phoenix, AZ', 50, :order => 'distance').where("LOWER(categories) LIKE ?", "%#{catego.downcase}%").limit(10)  
  end

  def show
    # Find the correct user.
    @user = User.where(id: params[:id]).first

    # Find 10 recent reviews by the user. We use eager loading here to reduce database queries.
    @recent_reviews = @user.reviews.includes(:business).order('created_at DESC').limit(10)
    @recommendations = []
    if Review.where(user_id: @user.id).first
    # Create new PredictionIO client.
      client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL'])

    # Query PredictionIO for 5 recommendations!
      object = client.send_query('user'=> @user.id, 'num' => 5)

    # Loop though item recommendations returned from PredictionIO.
      object['productScores'].each do |item|
      # Initialize empty recommendation hash.
        recommendation = {}

      # Each item hash has only one key value pair so the first key is the item ID (in our case the business ID).
        business_id = item.values.first

      # Find the business.
        business = Business.where(id: business_id).first
        recommendation[:business] = business

      # The value of the hash is the predicted preference score.
        score = item.values.second
        recommendation[:score] = score

      # Add to the array of recommendations.
        @recommendations << recommendation
      end
    end
  end
end
