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
end
