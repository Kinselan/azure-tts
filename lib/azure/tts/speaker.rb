# frozen_string_literal: true

module Azure
  module TTS
    class Speaker
      def initialize(text:, voice:, format:, rate:)
        @text = text
        @voice = voice
        @format = format
        @rate = rate || "1"
      end

      def speak
        puts "Speaking..."
        response = Azure::TTS.api.tts.post(nil, ssml, headers)
        raise RequestError, response unless response.success?

        response.body
      end

      def ssml
        puts "Generating SSML....rate: #{@rate.inspect} | @voice.short_name: #{@voice.short_name.inspect}"
        ssml = RubySpeech::SSML.draw
        ssml.voice gender: @voice.gender, name: @voice.short_name, language: @voice.locale do
          prosody rate: @rate.to_f do
            @text
          end
        end
        puts "*" * 100
        puts "ssml.to_s: #{ssml.to_s.inspect}"
        puts "*" * 100
        ssml.to_s
      end

      def headers
        {
          "Content-Type" => "application/ssml+xml",
          "X-Microsoft-OutputFormat" => Azure::TTS::AUDIO_FORMATS[@format],
          "User-Agent" => "Azure::TTS"
        }
      end
    end
  end
end

# speak = RubySpeech::SSML.draw do
#   voice gender: :male, name: 'fred' do
#     prosody rate: '50%' do
#       "my slow word"
#     end
#   end
# end

# speak.to_s
