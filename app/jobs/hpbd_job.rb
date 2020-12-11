require 'slack-ruby-client'

class HpbdJob < ApplicationJob
  
  queue_as :default 

  def perform
    client = Slack::Web::Client.new
    client.auth_test
    users = User.all
    users_data = []
    users_near_data = []
    users_client = client.users_list['members']

    users.each do |user|
      if Job::HandleJob.birthdaythisyear(user.birthday) == Time.zone.now.to_date
        users_data.push(user)
      end
      if ((Job::HandleJob.birthdaythisyear(user.birthday) - Time.zone.now.to_date) <=10) && 
      ((Job::HandleJob.birthdaythisyear(user.birthday) - Time.zone.now.to_date) > 0)
        users_near_data.push(user)
      end
    end

    return unless users_data.present?

    users_data.each do |user_data|
      wishing_user(users_client, user_data, client)
    end

    return unless users_near_data.present?

    birthday_comming(users_near_data, client, users_client)
  end

  def birthday_comming(users_near_data, client, users_client)
    tag_names = []

    users_near_data.each do |user_data|
      user_client = users_client.detect { |user| user['profile']['display_name'].index(user_data.nickname) }
      
      user_name =
        if user_client.present?
          '<@' + user_client['id'] + '|cal> '
        else
          user_data.name + ' (' + user_data.nickname + ')'
        end
        
      text = user_name + '- ' + '(' +(user_data.birthday).strftime(DM_FORMAT).to_s + ')'
      tag_names.push(text)
    end

    string = get_string_tag_name(tag_names)
    message_send = I18n.t('mutipledash')
    message_send = message_send + I18n.t('upcoming',tagnames: string) + I18n.t('link',link: ENV['LINK'])
    client.chat_postMessage(channel: ENV['SLACK_CHANNEL'],text: message_send,as_user: true)
  end

  def wishing_user(users_client, user_data, client)
    user_client = users_client.detect { |user| user['profile']['display_name'].index(user_data.nickname) }

    string = ""
    text = ''
    text =
      if user_client
        text + '<@' + user_client['id'] + '|cal>'
      else
        text + "#{user_data.name} (#{user_data.nickname})"
      end
    string = I18n.t('wish', name: text) + "\n"
    messages = Message.where(user_id: user_data.id)

    if messages.first.present?
      string = string + I18n.t('statement') + "\n"
      
      messages.each do |message|
        string = string + '*From ' + message.sendername + ':*' + "\n"
        string = string  + message.content + "\n"
      end 
    end
    client.chat_postMessage(channel: ENV['SLACK_CHANNEL'],text: string, as_user: true)
  end

  def get_string_tag_name tag_names
    string = ''
    temp1 = 0
    tag_names.each do |tag_name|
      temp1 += 1
      string += (temp1 == tag_names.size) ? (tag_name) : (tag_name + ', ')
    end
    return string
  end
end