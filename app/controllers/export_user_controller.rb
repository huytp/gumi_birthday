class ExportUserController < ApplicationController
  def index
    csv = Csv::ExportUserCsv.new User.all, User::CSV_ATTRIBUTES
    respond_to do |format|
      format.html
      format.csv { send_data csv.perform,
        filename: "users.csv" }
    end
  end
end
