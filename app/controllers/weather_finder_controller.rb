class WeatherFinderController < ApplicationController
  # skip_before_action :protect_pages

  BASE_URL = 'http://api.weatherapi.com/v1/forecast.json'

  def index
    keyword = params[:query_text]&.downcase
    city = nil
    return unless keyword

    city = search_keyword_in_db(keyword)
    if city.nil?
      query = FetchWeatherService.new(keyword).perform
      return if query.nil?

      values = {}
      values[:iata] = keyword
      values[:region] = query['location']['region']
      values[:country] = query['location']['country']
      # values[:temperature] = query['current']['temp_c']
      values[:latitude] = query['location']['lat']
      values[:longitude] = query['location']['lon']
      # values[:last_updated] = query['current']['last_updated'].to_datetime

      city = City.find_or_create_by(values)
      city.update!(temperature: query['current']['temp_c'], last_updated: query['current']['last_updated'].to_datetime)
    end

    respond_to do |format|
      format.html { redirect_to(weather_finder_index_path(city)) }
      format.turbo_stream do
        # el primer favorite se refiere al id del html a reemplazar
        render(
          turbo_stream: turbo_stream.replace(
            'weather_response', partial: 'weather', locals: { city: city }
          )
        )
      end
    end
  end

  private

  def search_keyword_in_db(keyword)
    date_range = Time.now.beginning_of_day..Time.now.end_of_day
    city = City.find_by(iata: keyword, last_updated: date_range)

    return nil if city.nil?

    city
  end
end
