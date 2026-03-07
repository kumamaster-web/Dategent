class MatchesController < ApplicationController
  before_action :set_match, only: [:show]

  def index
    @matches = current_user_matches
      .order(updated_at: :desc)
    @matches = @matches.where(status: params[:status]) if params[:status].present?
  end

  def show
    @date_events = @match.date_events.includes(:venue).order(created_at: :desc)
    @date_event = @date_events.order(created_at: :desc).first
    @transcripts = @match.transcript_history

    @current_user = current_user
    @recommended_venues =
      @match.matches_venues.map do |matchesvenue|
        venue_id = matchesvenue.venue_id
        Venue.find(venue_id)
    # iterate over each matchesvenue \ / and isolate the ID and find it then return
    # all of the five venues using the venue_ID as a reference
      end
  end

  def update
    # get selected venue (needs to be done with strong params)
    @match = Match.find(params[:id]) # loads match from the DB

    if @match.update(match_params)
      @date_event = @match.date_events
      @date_event.update(
        booking_status: "proposed",
        venue_id: @match.selected_venue_id
      )
      redirect_to match_path(@match), notice: "Venue selected."
    else
      redirect_to match_path(@match), alert: "Could not save venue."
    end
    # update my match with selected venue
  end

  private

  def set_match
    @match = current_user_matches.find(params[:id])
  end

  def current_user_matches
    return Match.none unless current_user.agent

    Match.where(
      "initiator_agent_id = ? OR receiver_agent_id = ?",
      current_user.agent.id, current_user.agent.id
    ).includes(initiator_agent: :user, receiver_agent: :user)
  end

  def match_params
    params.require(:match).permit(:selected_venue_id)
  end
end
