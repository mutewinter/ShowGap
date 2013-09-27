require 'test_helper'

class ReplyTest < AcceptanceTest
  it 'should allow a user to suggest a reply in a question', js: true do
    # Create the models used in this test
    discussion = Fabricate(:question)
    set_show discussion.episode.show

    user = Fabricate(:listener)
    reply = Fabricate.build(:reply)

    add_reply(reply, discussion, user)

    must_have_content reply.title
  end

  it 'should allow a host to create a reply in a question', js: true do
    # Create the models used in this test
    discussion = Fabricate(:question)
    set_show discussion.episode.show

    user = Fabricate(:host)
    reply = Fabricate.build(:reply)

    add_reply(reply, discussion, user)

    must_have_content reply.title
  end

  it 'should not allow a listener to create a reply with replies closed',
    js: true do
    # Create the models used in this test
    discussion = Fabricate(:question, replies_open: false)
    set_show discussion.episode.show

    user = Fabricate(:listener)
    reply = Fabricate.build(:reply)

    add_reply(reply, discussion, user)

    refute page.text.include?(reply.title)
  end

  it 'should allow a listener to vote on a reply when voting is open', js: true do
    vote_on_reply

    # Wait until the highlight shows, which indicates a vote succeeded
    find('.discussion-reply').has_css? '.highlight'

    # TODO
    # Find a way to use RSpec .should have_text style for this test
    assert_equal '1', find('.vote-amount').text
  end

  it 'should disallow a listener to vote when voting is closed', js: true do
    vote_on_reply(Fabricate(:discussion, voting_open: false))
    assert_equal '0', find('.vote-amount').text
  end

  it 'should disallow unique titles when unique_replies is set', js: true do
    discussion = Fabricate(:question, unique_replies: true)
    set_show discussion.episode.show

    user = Fabricate(:listener)
    reply = Fabricate.build(:reply)

    log_user_in user

    visit "/#episodes/#{discussion.episode.id}/discussions/#{discussion.id}"

    2.times do
      within('.new-reply')  do
        fill_in 'title', with: reply.title
        click_on 'Add'
      end
    end

    must_have_content 'has already been submitted.'
  end


  # ----------------------
  # Helpers
  # ----------------------

  # Internal: Uses Capybara to add a reply to the given discussion for the
  # given user
  #
  # reply      - Reply ActiveRecord model that preferably has not been saved.
  # discussion - Discussion ActiveRecord model that has been saved.
  # user       - User ActiveRecord model that has been saved.
  #
  # Returns nothing.
  def add_reply(reply, discussion, user)
    log_user_in user
    visit "/#episodes/#{discussion.episode.id}/discussions/#{discussion.id}"

    within('.new-reply')  do
      fill_in 'title', with: reply.title
      fill_in 'text', with: reply.text
      click_on 'Add'
    end
  end

  # Internal: Has a user vote on a reply for a given (or default) discussion.
  #
  # discussion - Discussion Model to use for creating the reply (default: the
  #              regular :discussion fabricator).
  #
  # Returns nothing.
  def vote_on_reply(discussion = Fabricate(:discussion))
    reply = Fabricate(:suggested, discussion: discussion)
    episode = discussion.episode
    show = episode.show

    set_show show

    user = Fabricate(:listener)

    log_user_in user
    visit "/#episodes/#{episode.id}/discussions/#{discussion.id}"

    within('.vote-arrows') do
      find('.js-vote-up').click
    end

  end
end
