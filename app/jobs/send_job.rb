require 'slack-ruby-client'

class SendJob < ApplicationJob

  queue_as :send_job
  
  def perform(user,message)
      if (Time.current.to_date == Job::HandleJob.birthdaythisyear(user.birthday)) &&
      (Time.current.strftime(HM_FORMAT) > ENV['STARTS'])
        client = Slack::Web::Client.new
        users_client = client.users_list['members']
        user_client = users_client.detect{|user_client| user_client['profile']['display_name']&.downcase.index(user.nickname.downcase)}
        string =
        if user_client.present?
          'Hi ' + '<@' + user_client['id'] + '|cal> ' + "\n  " + I18n.t('wishesnew') + '*From ' + message.sender_name + ':*' + "\n" + message.content + "\n"
        else
          'Hi ' + user.name + "\n" + I18n.t('wishesnew') + "*From #{message.sender_name}:*\n" + "#{message.content}\n"
        end 
        client.chat_postMessage(channel: ENV['SLACK_CHANNEL'],text: string, as_user: true)
      end
  end
end