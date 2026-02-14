RubyLLM.configure do |config|
  # Google Gemini via Vertex AI Express (API key auth)
  config.gemini_api_key = ENV['GEMINI_API_KEY'] || Rails.application.credentials.dig(:gemini_api_key)
  config.vertexai_project_id = ENV['GOOGLE_CLOUD_PROJECT']
  config.vertexai_location = ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1'

  config.default_model = "gemini-2.5-flash"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end

# Patch VertexAI provider to support Vertex AI Express (API key instead of OAuth2)
module RubyLLM
  module Providers
    class VertexAI < Gemini
      def headers
        { 'x-goog-api-key' => @config.gemini_api_key }
      end
    end
  end
end
