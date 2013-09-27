class ShowsController < ApplicationController
  respond_to :json
  load_and_authorize_resource

  def index
    @shows = Show.all
    respond_with @shows
  end

  def show
    @show = Show.find(params[:id])
    respond_with @show
  end

  def create
    respond_with @show = Show.create(show_params)
  end

  def update
    respond_with @show = Show.update(params[:id], show_params)
  end

  def destroy
    respond_with @show = Show.destroy(params[:id])
  end

  private
    # Internal: Uses the Rails strong_parameters gem to filter only valid
    # parameters and return 404's if bad things happen.
    #
    # Returns a hash of the valid parameters
    def show_params
      if can? :manage, Show
        params.require(:show).permit(:title, :description, :live)
      else
        {}
      end
    end
end
