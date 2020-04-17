class LinebotController < ApplicationController
  require 'line/bot'


  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      word = ["ないすで〜す", "ナイス！", "いい感じ！", "ナイスバルク！", "キレてるよ！", "バリバリ！", "仕上がってるよ！", "はい！ずどーん！", "腹筋グレネード！","肩メロン！", "背中に羽が生えてる！", "脚が歩いてる！"].sample
      fixed_word = ["筋トレしろ", "筋繊維を切れ", "続けなさい", "時々休め", "筋肉痛に感謝しろ", "筋肉と友達になれ"]
      case event.message['text']
      when /.*(終わった|おわた｜おわった|終了|できた|おわったよ|終わったよ|できたよ).*/
        push = "#{word}"
      else
        push = "#{fixed_word}"
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: push
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
