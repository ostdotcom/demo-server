class ApplicationController < ActionController::Base
  # Protect from forgery
  #
  protect_from_forgery with: :exception

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
    http_code = 404
    if request.xhr?
      response = Result.error("a_c_ac_1", "NOT_FOUND", "Page not found")
      (render plain: Oj.dump(response, mode: :compat), status: http_code) and return
    else
      render file: "public/#{http_code}.html", layout: false, status: http_code and return
    end
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
    response.headers["Content-Type"] = 'text/html; charset=utf-8'
  end

  # Sanitize params
  #
  def sanitize_params
    sanitize_params_recursively(params)
  end

end
