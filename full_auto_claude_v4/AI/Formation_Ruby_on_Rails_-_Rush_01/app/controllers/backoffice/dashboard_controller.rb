# frozen_string_literal: true

module Backoffice
  class DashboardController < BaseController
    def index
      @users_count = User.count
      @clients_count = Client.count
      @projects_count = Project.count
      @surveys_count = Survey.count
    end
  end
end
