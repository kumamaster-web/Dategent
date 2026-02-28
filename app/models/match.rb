class Match < ApplicationRecord
  belongs_to :initiator_agent, class_name: "Agent"
  belongs_to :receiver_agent, class_name: "Agent"

  has_many :date_events, dependent: :destroy
  has_many :match_transcripts, dependent: :destroy

  STATUSES = %w[screening evaluating date_proposed confirmed declined].freeze

  validates :status, inclusion: { in: STATUSES }

  # Dynamic status query methods: screening?, evaluating?, confirmed?, etc.
  STATUSES.each do |s|
    define_method(:"#{s}?") { status == s }
  end

  def initiator_user
    initiator_agent.user
  end

  def receiver_user
    receiver_agent.user
  end

  # Returns transcripts ordered by stage progression (not just created_at)
  def transcript_history
    stage_order = STATUSES.index_by { |s| s }
    match_transcripts.chronological.sort_by { |t| STATUSES.index(t.stage) || 99 }
  end

  # Append a transcript for the current stage
  def record_transcript!(stage, content)
    match_transcripts.find_or_initialize_by(stage: stage).update!(content: content)
  end
end
