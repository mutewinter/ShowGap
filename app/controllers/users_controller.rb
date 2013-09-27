class UsersController < ApplicationController
  respond_to :json
  load_and_authorize_resource

  def show
    respond_with @user = User.find(params[:id])
  end

  private
    # Uses the Rails strong_parameters gem to filter only valid parameters
    # and return 404's if bad things happen
    #
    # Returns a hash of the valid parameters
    def user_params
      params.require(:user).permit(:name)
    end
end
