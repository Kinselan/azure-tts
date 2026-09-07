# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class Azure::SpeakerTest < Minitest::Spec
  def speaker(text:, azure_tts_pinyin: "mo 2 wan 2", include_phoneme: false)
    Azure::TTS::Speaker.new(
      text: text,
      azure_tts_pinyin: azure_tts_pinyin,
      voice_short_name: "zh-CN-YunxiNeural",
      rate: 1.0,
      include_phoneme: include_phoneme
    )
  end

  def parse(ssml)
    REXML::Document.new(ssml)
  end

  it "escapes an ampersand in the text rather than emitting malformed XML" do
    ssml = speaker(text: "魔丸&灵珠").ssml_word

    assert_includes ssml, "魔丸&amp;灵珠"
    refute_includes ssml, "魔丸&灵珠"
  end

  it "produces a document that parses, for every XML metacharacter" do
    ssml = speaker(text: %(a & b < c > d " e ' f)).ssml_word

    assert parse(ssml) # raises REXML::ParseException if malformed
  end

  it "round-trips the original text through the parser" do
    ssml = speaker(text: "魔丸&灵珠").ssml_word
    spoken = parse(ssml).get_elements("//prosody").first.text.strip

    assert_equal "魔丸&灵珠", spoken
  end

  it "escapes the phoneme attribute too" do
    ssml = speaker(text: "字", azure_tts_pinyin: %(zi" & 4), include_phoneme: true).ssml_word

    assert parse(ssml)
    assert_equal %(zi" & 4), parse(ssml).get_elements("//phoneme").first.attributes["ph"]
  end

  it "leaves text with no metacharacters untouched" do
    ssml = speaker(text: "他是一个福瑞爱好者。").ssml_word

    assert_includes ssml, "他是一个福瑞爱好者。"
  end

  it "escapes the sentence form as well" do
    assert_includes speaker(text: "a & b").ssml, "a &amp; b"
  end

  it "handles nil text without raising" do
    assert parse(speaker(text: nil).ssml_word)
  end
end
