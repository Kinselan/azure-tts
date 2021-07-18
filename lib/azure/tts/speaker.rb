# frozen_string_literal: true

module Azure
  module TTS
    class Speaker
      def initialize(text:, azure_tts_pinyin:, voice_short_name:, rate:)
        @text = text
        @azure_tts_pinyin = azure_tts_pinyin
        @voice_short_name = voice_short_name
        @rate = rate
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
            <voice name="#{@voice_short_name}">
              <prosody rate="#{@rate}" pitch="0%">
                #{@text}
              </prosody>
            </voice>
          </speak>
        HEREDOC
      end

      def ssml_word
        # <<~HEREDOC
        #   <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
        #     <voice name="#{@voice_short_name}">
        #       <prosody rate="#{@rate}" pitch="0%">
        #         <phoneme alphabet="sapi" ph="#{@azure_tts_pinyin}">#{@text}</phoneme>               
        #       </prosody>
        #     </voice>
        #   </speak>
        # HEREDOC

        <<~HEREDOC
          <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
            <voice name="zh-CN-XiaoxiaoNeural">
              <prosody rate="0%" pitch="0%">
                <phoneme alphabet="sapi" ph="hang 2">行</phoneme>
              </prosody>
            </voice>
          </speak>
        HEREDOC
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
