class LinebotController < ApplicationController
  require 'line/bot'
  require 'open-uri'

  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      return head :bad_request
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          input = event.message['text']
          case input
          when /.*(終わった|おわった|おわた|できた|終了|完了|したよ|した).*/
            word = ["ないすで〜す", "ナイス！", "いい感じ！", "ナイスバルク！", "キレてるよ！", "バリバリ！", "仕上がってるよ！", "はい！ずどーん！", "腹筋グレネード！","肩メロン！", "背中に羽が生えてる！", "脚が歩いてる！"].sample
            push = "#{word}"
          end
          else
            push = "テキスト以外はわからないよ〜"
          end
          message = {
            type: 'text',
            text: push
          }
          client.reply_message(event['replyToken'], message)

        when Line::Bot::Event::Follow
          line_id = event['source']['userId']
          User.create(line_id: line_id)
        when Line::Bot::Event::Unfollow
          line_id = event['source']['userId']
          User.find_by(line_id: line_id).destroy
        end
        }
        head :ok
  end

  private 

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
end
