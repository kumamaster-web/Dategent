RubyLLM.configure do |config|
  # Google Gemini via Google AI Studio (API key auth)
  config.gemini_api_key = ENV['GEMINI_API_KEY'] || Rails.application.credentials.dig(:gemini_api_key)

  config.default_model = "gemini-2.5-flash-lite"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
