# frozen_string_literal: true

require "cgi"

module Azure
  module TTS
    class Speaker
      def initialize(text:, azure_tts_pinyin:, voice_short_name:, rate:, include_phoneme:)
        @text = text
        @azure_tts_pinyin = azure_tts_pinyin
        @voice_short_name = voice_short_name
        @rate = rate
        @include_phoneme = include_phoneme
      end

      def speak
        response = Azure::TTS.api.tts.post(nil, ssml_word, headers)
        raise RequestError, response unless response.success?

        response.body
      end

      # sentences
      def ssml
        <<~HEREDOC
          <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
            <voice name="#{escape(@voice_short_name)}">
              <prosody rate="#{escape(@rate)}" pitch="0%">
                #{escape(@text)}
              </prosody>
            </voice>
          </speak>
        HEREDOC
      end

      def ssml_word
        if @include_phoneme
          <<~HEREDOC
            <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
              <voice name="#{escape(@voice_short_name)}">
                <prosody rate="#{escape(@rate)}" pitch="0%">
                  <phoneme alphabet="sapi" ph="#{escape(@azure_tts_pinyin)}">#{escape(@text)}</phoneme>
                </prosody>
              </voice>
            </speak>
          HEREDOC
        else
          <<~HEREDOC
            <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
              <voice name="#{escape(@voice_short_name)}">
                <prosody rate="#{escape(@rate)}" pitch="0%">
                  #{escape(@text)}
                </prosody>
              </voice>
            </speak>
          HEREDOC
        end
      end

      # Every value here is interpolated into an XML document, as either a text
      # node or an attribute value. Without escaping, a caller passing text that
      # contains "&" or "<" produces malformed SSML and the API rejects the
      # request. Callers pass raw text and should not pre-escape.
      def escape(value)
        CGI.escapeHTML(value.to_s)
      end

      def headers
        {
          "Content-Type" => "application/ssml+xml",
          "X-Microsoft-OutputFormat" => "audio-24khz-160kbitrate-mono-mp3",
          "User-Agent" => "Azure::TTS"
        }
      end
    end
  end
end
