class DateEventsController < ApplicationController
  before_action :set_date_event

  def show
  end

  def accept
    if @date_event.update(booking_status: "accepted")
      redirect_to match_path(@date_event.match), notice: "Date accepted! It's a date! 🎉"
    else
      redirect_to match_path(@date_event.match), alert: "Could not accept this date."
    end
  end

  def decline
    reason = params[:decline_reason]
    if @date_event.update(booking_status: "declined")
      redirect_to match_path(@date_event.match), notice: "Date declined."
    else
      redirect_to match_path(@date_event.match), alert: "Could not decline this date."
    end
  end

  private

  def set_date_event
    @date_event = DateEvent.joins(:match).where(
      "matches.initiator_agent_id = ? OR matches.receiver_agent_id = ?",
      current_user.agent&.id, current_user.agent&.id
    ).find(params[:id])
  end
end
