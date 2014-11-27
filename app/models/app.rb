class App < ActiveRecord::Base
  DEFAULT_API_RPM = 10
  before_create do |doc|
    doc.api_key = App.generate_api_key
    doc.api_rpm = DEFAULT_API_RPM if doc.api_rpm == 0
  end
  
  def self.generate_api_key
    loop do
      token = SecureRandom.base64.tr('0+/=','bRat')
      break token unless App.exists?(api_key: token)
    end
  end
end
