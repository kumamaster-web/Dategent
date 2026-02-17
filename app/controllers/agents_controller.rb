class AgentsController < ApplicationController
  before_action :set_agent

  def show
  end

  def edit
  end

  def update
    if @agent.update(agent_params)
      redirect_to agent_path, notice: "Agent settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_agent
    @agent = current_user.agent || current_user.create_agent(
      name: "Agent #{current_user.first_name}",
      personality_mode: "friendly",
      match_cap_per_week: 5
    )
  end

  def agent_params
    params.require(:agent).permit(
      :name, :personality_mode, :match_cap_per_week,
      :personality_summary, :autopilot
    )
  end
end
