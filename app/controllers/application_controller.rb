class ApplicationController < ActionController::Base
  # Protect from forgery.
  #
  # protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  # Sanitize params.
  #
  include Sanitizer
  before_action :sanitize_params

  # Set headers.
  #
  after_action :set_response_headers

  include ApplicationHelper

  # Render API response.
  #
  def render_api_response(response)
    unless response[:success]
      Rails.logger.error("error in API Call: #{response}")
    end
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Handle error response.
  #
  def error
    if params[:code].to_i == 404
      response = Result.error("a_c_ac_1", "NOT_FOUND", "Page not found")
    elsif params[:code].to_i == 400
      response = Result.error("a_c_ac_2", "BAD_REQUEST", "Bad request")
    elsif params[:code].to_i == 422
      response = Result.error("a_c_ac_3", "UNPROCESSABLE_ENTITY", "Unprocessable entity")
    else
      response = Result.error("a_c_ac_4", "SOMETHING_WENT_WRONG", "Something went wrong")
    end
    (render plain: Oj.dump(response, mode: :compat), status: (params[:code] || 500)) and return
  end

  # ELB health checker.
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

  # Sanitize params.
  #
  def sanitize_params
    sanitize_params_recursively(params)
  end

  # Set cookie.
  #
  def set_cookie(cookie_name, value, expires)
    cookies[cookie_name.to_sym] = {
      value: value,
      expires: expires,
      domain: ENV['DEMO_COOKIE_DOMAIN'],
      http_only: true,
      secure: false,
      same_site: :strict
    }
  end

  # Delete cookie.
  #
  def delete_cookie(cookie_name)
    cookies.delete(
      cookie_name.to_sym,
      domain: ENV['DEMO_COOKIE_DOMAIN'],
      secure: !Rails.env.development?,
      same_site: :strict
    )
  end

  # Decrypt jwt.
  #
  def decrypt_jwt
    begin
      decoded_token_data = JWT.decode(
          params[:token],
          GlobalConstant::Base.kit_secret_key,
          true,
          {:algorithm => 'HS256'}
      )[0]["data"]

      params[:decoded_token_data] = HashWithIndifferentAccess.new(decoded_token_data)
    rescue => e
      # Decoding failed.
      response = Result.error("a_c_ac_5", "UNAUTHORISED", "Not allowed to access the endpoint")
      (render plain: Oj.dump(response, mode: :compat), status: '401') and return
    end
  end

end
