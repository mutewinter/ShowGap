class EpisodesController < ApplicationController
  respond_to :json
  load_and_authorize_resource

  def index
    @episodes = @show.episodes.all
    respond_with @episodes
  end

  def show
    @episode = @show.episodes.find(params[:id])
    respond_with @episode
  end

  def create
    respond_with @episode = @show.episodes.create(episode_params)
  end

  def update
    respond_with @episode = @show.episodes.update(params[:id], episode_params)
  end

  def destroy
    respond_with @episode = @show.episodes.destroy(params[:id])
  end

  private
    # Uses the Rails strong_parameters gem to filter only valid parameters
    # and return 404's if bad things happen
    #
    # Returns a hash of the valid parameters
    def episode_params
      if can? :manage, Episode
        params.require(:episode).permit(:title, :slug, :state, :record_date)
      else
        {}
      end
    end
end
