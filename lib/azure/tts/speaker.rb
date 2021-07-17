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
        <<~HEREDOC
          <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
            <voice name="zh-CN-XiaoxiaoNeural">
              <prosody rate="#{@rate}" pitch="0%">
                #{@text}
              </prosody>
            </voice>
          </speak>
        HEREDOC
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
