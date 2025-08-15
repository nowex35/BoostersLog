class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  
  def index
    users = User.all
    render json: { users: users, count: users.count }
  end

  def show
    user = User.find(params[:id])
    render json: { user: user }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def create
    uid = user_params[:uid]

    if User.exists?(firebase_local_id: uid)
      render json: { error: 'User already exists' }, status: :unprocessable_entity
      return
    end

    user = User.new(
      firebase_local_id: uid,
      name: user_params[:name],
      email: user_params[:email]
    )

    if user.save
      render json: { user: user, message: 'User created successfully' }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def me
    if current_user
      render json: { user: current_user }
    else
      render json: { error: 'Authentication failed' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:uid, :name, :email)
  end
end
