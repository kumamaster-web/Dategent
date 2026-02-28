# frozen_string_literal: true

class MatchTranscript < ApplicationRecord
  belongs_to :match

  STAGES = Match::STATUSES

  validates :stage, presence: true, inclusion: { in: STAGES }
  validates :content, presence: true
  validates :stage, uniqueness: { scope: :match_id, message: "already has a transcript for this stage" }

  scope :chronological, -> { order(:created_at) }

  # Human-readable stage labels for the UI
  STAGE_LABELS = {
    "screening"     => "Initial Screening",
    "evaluating"    => "Deep Evaluation",
    "date_proposed" => "Date Negotiation",
    "confirmed"     => "Confirmation",
    "declined"      => "Declined"
  }.freeze

  def stage_label
    STAGE_LABELS[stage] || stage.titleize
  end

  # Icon name for timeline display
  STAGE_ICONS = {
    "screening"     => "magnifying-glass",
    "evaluating"    => "chart-bar",
    "date_proposed" => "calendar",
    "confirmed"     => "check-circle",
    "declined"      => "x-circle"
  }.freeze

  def stage_icon
    STAGE_ICONS[stage] || "chat-bubble"
  end
end
