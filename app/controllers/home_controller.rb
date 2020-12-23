class HomeController < ApplicationController
  def index
    @user = User.all
    @event = []
    @message = Message.new
    @user.each do |user|
      @event.push({
        user_id: user.id,
        title: user[:name] + " (" + user[:nickname] + ")",
        start: birthdaythisyear(user[:birthday]),
        end: birthdaythisyear(user[:birthday] + 1.day)
      })
    end
  end

  def create
    message = Message.new
    message.user_id = params[:message][:user_id]
    message.content = params[:message][:content]
    message.sendername = params[:message][:sendername]
    message.createdate = params[:message][:createdate]
    user = User.find_by(id: params[:message][:user_id])
    name = user.name + " (" + user.nickname + ")"

    if message.save
      flash[:success] = I18n.t('thankyou',name: name)
      SendJob.set(wait: 5.second).perform_later(user,message)
    else
      flash[:error] = I18n.t('sentfail')
    end
    redirect_to root_url
  end


  private 

  def birthdaythisyear(birthday)
    daymonth = birthday.to_s.slice(4...birthday.to_s.size)
    birthday = Date.parse(Time.zone.now.year.to_s + daymonth)

    if (birthday < Date.current)
      (Time.now.year + 1).to_s + daymonth
    else
      Time.now.year.to_s + daymonth
    end 
  end 
end
