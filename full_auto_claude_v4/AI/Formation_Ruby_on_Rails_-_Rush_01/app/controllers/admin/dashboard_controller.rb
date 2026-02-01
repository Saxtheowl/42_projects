# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @users_count = User.count
      @clients_count = Client.count
      @projects_count = Project.count
      @recent_activity = ActivityLog.by_date.limit(20)
    end
  end
end
