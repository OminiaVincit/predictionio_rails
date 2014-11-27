class Api::ApiController < ActionController::Base
  respond_to :json
  private
  
  def authenticate
      authenticate_or_request_with_http_token do |token, options|
        @app = App.where(api_key: token).first
      end
    end

    # NOTE: For ref
    # Manual way of authenticate request
    def authenticate_manual 
      api_key = request.headers['X-Api-Key']
      @app = App.where(api_key: api_key).first if api_key

      unless @app
        head status: :unauthorized
        return false
      end
    end

    # Check request per min
    # You can add field to user table request per min or define constant. 
    # Here I am just passsing some random value
    def validate_rpm
      if ApiRpmStore.threshold?(@app.id, @app.api_rpm) # 10 request per min
        render json: { help: 'http://prediction.io' }, status: :too_many_requests
        return false
      end
    end
end
