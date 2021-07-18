# frozen_string_literal: true

require "azure/tts/version"
require "faraday"
require "faraday_middleware"
require "azure/tts/constants"
require "azure/tts/errors"
require "azure/tts/api"
require "azure/tts/configuration"
require "azure/tts/token"
require "azure/tts/speaker"
require "azure/tts/voices"

module Azure
  module TTS
    include Azure::TTS::Constants

    module_function

    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
      reset
    end

    def voices
      @voices ||= Voices.new
    end

    def speak(text:, azure_tts_pinyin:, voice_short_name:, rate:)
      Speaker.new(text: text, azure_tts_pinyin: azure_tts_pinyin, voice_short_name: voice_short_name, rate: rate).speak
    end

    def token
      @token ||= Token.new
      @token.tap(&:refresh)
    end

    def api
      @api ||= API.new
    end

    def reset
      @api = nil
      @voices = nil
      @token = nil
    end
  end
end
