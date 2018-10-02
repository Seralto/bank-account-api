class ApplicationController < ActionController::API
  attr_reader :current_user
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  def record_not_found(error)
    render json: { error: error.message }, status: :not_found
  end
end
