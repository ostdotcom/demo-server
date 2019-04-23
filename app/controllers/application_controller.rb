class ApplicationController < ActionController::Base
  # Protect from forgery
  #
  # protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  # Sanitize params
  #
  include Sanitizer
  before_action :sanitize_params

  # Set headers
  #
  after_action :set_response_headers

  include ApplicationHelper

  # Page not found action
  #
  def not_found
    response = Result.error("a_c_ac_1", "NOT_FOUND", "Page not found")
    (render plain: Oj.dump(response, mode: :compat), status: 404) and return
  end

  # Handle error response
  #
  def error
    response = Result.error("a_c_ac_2", "SOMETHING_WENT_WRONG", "Something went wrong")
    (render plain: Oj.dump(response, mode: :compat), status: (params[:code] || 500)) and return
  end

  # ELB Health Checker
  #
  def health_checker
    render plain: '', :status => 200
  end

  private

  # Set response headers
  #
  def set_response_headers
    response.headers["X-Content-Type-Options"] = 'nosniff'
    response.headers["X-Frame-Options"] = 'SAMEORIGIN'
    response.headers["X-XSS-Protection"] = '1; mode=block'
    response.headers["Content-Type"] = 'application/json; charset=utf-8'
  end

  # Sanitize params
  #
  def sanitize_params
    sanitize_params_recursively(params)
  end

  # Set cookie
  #
  def set_cookie(cookie_name, value, expires)
    cookies[cookie_name.to_sym] = {
      value: value,
      expires: expires,
      domain: ENV['DEMO_COOKIE_DOMAIN'],
      http_only: true,
      secure: !Rails.env.development?,
      same_site: :strict
    }
  end

  # Delete cookie
  #
  def delete_cookie(cookie_name)
    cookies.delete(
      cookie_name.to_sym,
      domain: ENV['DEMO_COOKIE_DOMAIN'],
      secure: !Rails.env.development?,
      same_site: :strict
    )
  end

end
