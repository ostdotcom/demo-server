class Api::BaseController < ApplicationController

  before_action :set_authenticate_user_params
  before_action :authenticate_user
  before_action :set_token_by_url_params

  private

  # Set authenticate user params.
  #
  def set_authenticate_user_params
    params[:token_user] = nil
    params[:token] = nil
  end

  # Authenticate user.
  #
  def authenticate_user
    token_user_cache = TokenUser.verify_cookie(cookies[GlobalConstant::Cookie.user_authentication_cookie.to_sym])
    if token_user_cache.blank?
      delete_cookie(GlobalConstant::Cookie.user_authentication_cookie)
      response = Result.error("a_c_a_m_bc_1", "UNAUTHORISED", "Not allowed to access the endpoint")
      (render plain: Oj.dump(response, mode: :compat), status: '401') and return
    else
      params[:token_user] = token_user_cache
    end
  end

  # Set token by url params.
  #
  def set_token_by_url_params
    params[:ost_token_id] = params[:ost_token_id].to_i

    if params[:token_user].present?
      token_id = params[:token_user][:token_id]
      params[:token] = CacheManagement::TokenById.new([token_id]).fetch()[token_id]
    else
      params[:token] = CacheManagement::TokenByOstDetail.new([params[:ost_token_id]], {url_id: params[:url_id]}).fetch()[params[:ost_token_id]]
    end

    if params[:token].blank? ||
      params[:token][:url_id] != params[:url_id] ||
      params[:token][:ost_token_id] != params[:ost_token_id] ||
      (params[:token_user].present? && params[:token_user][:token_id] != params[:token][:id])
      response = Result.error("a_c_a_m_bc_2", "UNAUTHORISED", "Not allowed to access the endpoint")
      (render plain: Oj.dump(response, mode: :compat), status: '401') and return
    end
  end

end
