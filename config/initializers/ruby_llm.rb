RubyLLM.configure do |config|
  # Google Gemini via Google AI Studio (API key auth)
  config.gemini_api_key = ENV['GEMINI_API_KEY'] || Rails.application.credentials.dig(:gemini_api_key)
  config.vertexai_project_id = ENV['GOOGLE_CLOUD_PROJECT']
  config.vertexai_location = ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1'

  config.default_model = "gemini-2.5-flash-lite"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true

  config.gemini_api_base = 'https://generativelanguage.googleapis.com/v1beta'
end
