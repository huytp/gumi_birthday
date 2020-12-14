require 'slack-ruby-client'

class SendJob < ApplicationJob

  queue_as :default 
  
  def perform(user,message)
    if (Time.zone.now.to_date == user.birthday) &&
      (Time.zone.now.strftime('%H:%M') > "09:00")
        client = Slack::Web::Client.new
        users_client = client.users_list['members']
        user_client = users_client.detect{|user_client| user_client['profile']['display_name']&.downcase.index(user.nickname.downcase)}
        if user_client.present?
          string = 'Hi ' + '<@' + user_client['id'] + '|cal> ' + "\n  " + I18n.t('wishesnew') + '*From ' + message.sendername + ':*' + "\n" + message.content + "\n"
        else
          string = 'Hi ' + user.name + "\n" + I18n.t('wishesnew') + "*From #{message.sendername}:*\n" + "#{message.content}\n"
        end 
        client.chat_postMessage(channel: ENV['SLACK_CHANNEL'],text: string, as_user: true)
      end
  end
end