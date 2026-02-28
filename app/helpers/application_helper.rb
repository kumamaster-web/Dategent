module ApplicationHelper
  def nav_link_classes(path)
    base = "flex flex-col items-center gap-1 text-xs transition-colors"
    if current_page?(path)
      "#{base} text-indigo-600 dark:text-indigo-400"
    else
      "#{base} text-gray-500 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400"
    end
  end

  def status_badge_classes(status)
    case status
    when "screening"
      "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
    when "evaluating"
      "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
    when "date_proposed"
      "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200"
    when "confirmed"
      "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
    when "declined"
      "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"
    else
      "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200"
    end
  end

  def booking_status_badge(status)
    case status
    when "proposed"
      "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
    when "accepted"
      "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
    when "declined"
      "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"
    when "cancelled"
      "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200"
    else
      "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200"
    end
  end

  def match_other_user(match)
    if match.initiator_agent.user == current_user
      match.receiver_agent.user
    else
      match.initiator_agent.user
    end
  end

  # ── Compatibility Breakdown Helpers ───────────────────────────────

  def mbti_compatibility_color(label)
    case label.to_s
    when "complementary"
      "bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300"
    when "similar"
      "bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300"
    when "neutral"
      "bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400"
    when "challenging"
      "bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300"
    else
      "bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400"
    end
  end

  def goal_alignment_badge(alignment)
    case alignment.to_s
    when "aligned"
      content_tag(:span, class: "inline-flex items-center gap-0.5 px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300") do
        raw('<svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>') + " Aligned"
      end
    when "partial"
      content_tag(:span, class: "inline-flex items-center gap-0.5 px-2 py-0.5 rounded-full text-xs font-medium bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300") do
        raw("~") + " Partial"
      end
    when "misaligned"
      content_tag(:span, class: "inline-flex items-center gap-0.5 px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300") do
        raw('<svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/></svg>') + " Misaligned"
      end
    else
      ""
    end
  end

  def lifestyle_dots(score, max: 4)
    filled = [score.to_i, max].min
    empty = max - filled
    dots = ("●" * filled) + ("○" * empty)
    color = if filled >= 3
              "text-emerald-500"
            elsif filled >= 2
              "text-amber-500"
            else
              "text-red-500"
            end
    content_tag(:span, dots, class: "text-sm tracking-wider #{color}")
  end

  def schedule_overlap_color(percentage)
    if percentage >= 60
      "text-emerald-600 dark:text-emerald-400"
    elsif percentage >= 30
      "text-amber-600 dark:text-amber-400"
    else
      "text-red-600 dark:text-red-400"
    end
  end
end
