class WeatherFinderController < ApplicationController
  # skip_before_action :protect_pages

  BASE_URL = 'http://api.weatherapi.com/v1/forecast.json'

  def index
    keyword = params[:query_text]&.downcase
    city = nil
    return unless keyword

    city = search_keyword_in_db(keyword)
    # city = search_keyword_in_cache(keyword).nil? ? nil : City.new(search_keyword_in_cache(keyword))

    if city.nil?
      query = FetchWeatherService.new(keyword).perform
      return if query.nil?

      values = store_to_hash(query, keyword)
      city = City.create(values)
      # city = City.new(store_to_cache(values))
    end

    respond_to do |format|
      format.html { redirect_to(weather_finder_index_path(city)) }
      format.turbo_stream do
        # el primer favorite se refiere al id del html a reemplazar
        render(turbo_stream: turbo_stream.replace('weather_response', partial: 'weather', locals: { city: city }))
      end
    end
  end

  def last_cities_searched
    @cities = City.order(created_at: :desc).limit(10)
  end

  private

  def search_keyword_in_db(keyword)
    date_range = Time.now.beginning_of_day..Time.now.end_of_day
    city = City.find_by(iata: keyword, last_updated: date_range)

    return if city.nil?

    city
  end

  def search_keyword_in_cache(keyword)
    Rails.cache.read(keyword)
  end

  def store_to_cache(values)
    Rails.cache.write(values[:iata], values) unless Rails.cache.write(values[:iata], values) == TrueClass
    Rails.cache.read(values[:iata])
  end

  def store_to_hash(query, keyword)
    values = {}
    values[:iata] = keyword
    values[:region] = query['location']['region']
    values[:country] = query['location']['country']
    values[:temperature] = query['current']['temp_c']
    values[:latitude] = query['location']['lat']
    values[:longitude] = query['location']['lon']
    values[:last_updated] = query['current']['last_updated'].to_time
    values
  end
end
