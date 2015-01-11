class UsersController < ApplicationController

  def create

  end

  def index
    catego = "restaurant"
    @users = User.order('reviews_count DESC').limit(20)
    
  end

  def show
    # Find the correct user.
    @user = User.where(id: params[:id]).first

    # Find 10 recent reviews by the user. We use eager loading here to reduce database queries.
    @recent_reviews = @user.reviews.includes(:business).order('created_at DESC').limit(10)
    
    @business_recommendations = []
    @restaurant_recommendations = []
    #@education_recommendations = []
    #@entertainment_recommendations = []
    #@shopping_recommendations = []
    #@hotel_recommendations = []
    #@beauty_recommendations = []
    
    if Review.where(user_id: @user.id).first
    # Create new PredictionIO client.
      business_client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL_BUSINESS'])
	  restaurant_client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL_RESTAURANT'])
	  #education_client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL_EDUCATION'])
	  #entertainment_client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL_ENTERTAINMENT'])
	  #shopping_client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL_SHOPPING'])
	  #hotel_client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL_HOTEL'])
	  #beauty_client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL_BEAUTY'])
	  
    # Query PredictionIO for 5 recommendations!
      object = business_client.send_query('user'=> @user.id, 'num' => 5)

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
        @business_recommendations << recommendation
      end
      
      # Query PredictionIO for 5 restaurant recommendations!
      object = restaurant_client.send_query('user'=> @user.id, 'num' => 5)

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
        @restaurant_recommendations << recommendation
      end
      
    end
    rescue => e
  end
end
