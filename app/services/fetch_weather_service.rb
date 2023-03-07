require 'net/http'

class FetchWeatherService
  attr_reader :keyword, :weather_apikey, :base_url

  def initialize(keyword)
    @keyword = keyword
    @weather_apikey = Rails.configuration.weather_apikey[:apikey]
    @base_url = 'http://api.weatherapi.com/v1/forecast.json'
  end

  def perform
    uri = URI("#{base_url}?key=#{weather_apikey}&q=#{keyword}&days=1&aqi=yes&alerts=no")
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    parsed_response unless parsed_response['error'].present?
  rescue StandardError
    'There are any problem with the Web Service!'
  end
end
