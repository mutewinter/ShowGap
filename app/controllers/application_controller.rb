class ApplicationController < ActionController::Base
  respond_to :json
  before_filter :find_show

  protect_from_forgery

  def find_show
    @show = Show.find_by_subdomain(request.subdomain)
    if request.subdomain != '' and !@show
      flash[:error] = "Show for subdomain '#{request.subdomain}' not found."
    end
  end

  def find_episode
    unless @show.blank? or params[:episode_id].blank?
      @episode = @show.episodes.find(params[:episode_id])
    end
  end

  def find_episode_and_discussion
    find_episode

    unless @episode.blank? or params[:discussion_id].blank?
      @discussion = @episode.discussions.find(params[:discussion_id])
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    @error = exception
    render 'sessions/error.json', status: 403
  end

  private

    # Public: Retriviews the current user based on the user_id field found in
    # their session.
    #
    # Returns the current user object.
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    helper_method :current_user
end
