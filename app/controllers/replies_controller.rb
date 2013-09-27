class RepliesController < ApplicationController
  respond_to :json
  before_filter :find_episode_and_discussion
  load_and_authorize_resource

  def index
    respond_with @discussion.discussions.all
  end

  def episode
    respond_with @reply = @discussion.replies.find(params[:id])
  end

  def create
    @reply = @discussion.replies.new(reply_params)

    unless  @reply.discussion.replies_open
      @error = { message: 'Replies disabled for this Discussion.' }
      render 'main/error.json', status: :forbidden

      return
    end

    @reply.author = current_user
    @reply.save

    respond_with(@episode, @discussion, @reply)
  end

  def update
    respond_with(@episode, @discussion,
                 @discussion.replies.update(params[:id], reply_params))
  end

  def destroy
    respond_with(@episode, @discussion,
                 @discussion.replies.destroy(params[:id]))
  end

  def vote
    @reply = @discussion.replies.find(params[:reply_id])

    unless  @reply.discussion.voting_open
      @error = { message: 'Voting Closed for this Discussion.' }
      render 'main/error.json', status: :forbidden

      return
    end

    direction = params[:direction]

    # Parameters all come in as stirngs, so we must check for the string "true"
    if params.has_key?(:already_voted)
      already_voted = params[:already_voted] == "true"
    end

    begin
      case direction
      when 'up'
        if already_voted
          # User has seen that they've already voted
          if current_user.voted_for? @reply
            # User has already voted for this, remove their vote.
            current_user.unvote_for @reply
          else
            # User is switching from a vote against to a vote for
            current_user.vote_exclusively_for @reply
          end
        else
          # User's first vote, and it's for
          current_user.vote_for @reply
        end
      when 'down'
        if already_voted
          # User has seen that they've already voted
          if current_user.voted_against? @reply
            # User has already voted against this, remove their vote.
            current_user.unvote_for @reply
          else
            # User is switchign from a vote for to a vote against.
            current_user.vote_exclusively_against @reply
          end
        else
          # User's first vote, and it's against.
          current_user.vote_against @reply
        end
      else
        respond_with @episode, @discussion, @reply,
          status: :unprocessable_entity
        return
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors
      render 'main/error.json', status: :unprocessable_entity
      return
    end
    respond_with @episode, @discussion, @reply
  end

   private
     # Uses the Rails strong_parameters gem to filter only valid parameters
     # and return 404's if bad things happen
     #
     # Returns a hash of the valid parameters
     def reply_params
       # TODO
       # Must also check if this reply was created by this user before allowing edit

       Rails.logger.info 'Constructing reply_params'

       allowed_params = []

       if can? :create, Reply
         allowed_params << [:title, :text, :reply_type]
       end

       if can? :manage, Discussion
         # Users who can manage discussions an change reply states.
         allowed_params << :reply_state
       end

       if can? :vote, Reply
         allowed_params << :direction
       end

       # Explode the params array into arguments for permit
       params.require(:reply).permit(*allowed_params.flatten)
     end
end
