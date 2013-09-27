class DiscussionsController < ApplicationController
  respond_to :json
  before_filter :find_episode
  load_and_authorize_resource

  def index
    respond_with @episode.discussions.all
  end

  def show
    respond_with @discussion = @episode.discussions.find(params[:id])
  end

  def create
    @discussion = @episode.discussions.new(discussion_params)
    @discussion.author = current_user
    @discussion.save

    respond_with(@episode, @discussion)
  end

  def update
    respond_with(@episode, @episode.discussions.update(params[:id],
                                                       discussion_params))
  end

  def destroy
    respond_with(@episode, @episode.discussions.destroy(params[:id]))
  end

   private
     # Uses the Rails strong_parameters gem to filter only valid parameters
     # and return 404's if bad things happen
     #
     # Returns a hash of the valid parameters
     def discussion_params
       if can? :manage, Discussion
         params.require(:discussion).permit(
           :title, :body, :reply_name,
           :episode_id,
           :discussion_type,
           :allows_url_replies, :allows_text_replies,
           :voting_open, :replies_open, :unique_replies
         )
       else
         {}
       end
     end
end
