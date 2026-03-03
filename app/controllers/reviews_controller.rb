class ReviewsController < ApplicationController
  def create
    # find the reviewer, it's current user
    @reviewer = current_user
    # find the reviewee, using the id in the url
    @reviewee = User.find(params[:user_id])
    # Create a new review instance
    @review = Review.new(params.require(:review).permit(:rating, :content))
    # bind the review instance to reviewee
    @review.reviewer = current_user
    # bind the review instance to reviewer
    @review.reviewee = @reviewee
    # save to database
    @review.save

    if @review.save
      redirect_to root_path
    else
      @match = Match.find_by(receiver_agent: @reviewee.agent, initiator_agent: @reviewer.agent)
      @date_events = @match.date_events.includes(:venue).order(created_at: :desc)
      @transcripts = @match.transcript_history
      render "matches/show", status: :unprocessable_entity
    end
  end

  private

end
