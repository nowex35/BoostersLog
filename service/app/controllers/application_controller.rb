class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    return if Rails.env.test?

    token = request.headers["Authorization"]&.gsub("Bearer ", "")

    return render_unauthorized unless token

    begin
      payload = FirebaseAuth::TokenValidator.new(token).validate!
      @current_user = User.find_or_create_by(firebase_local_id: payload["sub"])
    rescue FirebaseAuth::TokenValidator::InvalidTokenError => e
      render_unauthorized
    rescue => e
      render_unauthorized
    end
  end

  def current_user
    @current_user
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
