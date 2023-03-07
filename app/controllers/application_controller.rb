class ApplicationController < ActionController::Base
  include Authentication

  def save_in_cache
    Rails.cache.write('key', 'value')
  end
end
