class SessionsController < ApplicationController
  def new
  end

  def create
    if @user = User.find_or_create_from_auth_hash(auth_hash)
      session[:user_id] = @user.id
      redirect_to '/'
    else
      @error = {message: 'Unable to Create User.'}
      render 'main/error.json', status: :forbidden
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end

  private
    def auth_hash
      request.env['omniauth.auth']
    end
end
