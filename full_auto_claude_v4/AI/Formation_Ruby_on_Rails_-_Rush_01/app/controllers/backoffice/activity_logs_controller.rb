# frozen_string_literal: true

module Backoffice
  class ActivityLogsController < BaseController
    def index
      @activity_logs = ActivityLog.includes(:user, :trackable).by_date

      @activity_logs = @activity_logs.for_user(User.find(params[:user_id])) if params[:user_id].present?

      if params[:company_id].present?
        company = Company.find(params[:company_id])
        client_ids = company.clients.pluck(:id)
        @activity_logs = @activity_logs.where(trackable_type: 'Client', trackable_id: client_ids)
      end

      if params[:client_id].present?
        @activity_logs = @activity_logs.where(trackable_type: 'Client', trackable_id: params[:client_id])
      end

      @activity_logs = @activity_logs.page(params[:page]).per(50) if defined?(Kaminari)
      @activity_logs = @activity_logs.limit(100) unless defined?(Kaminari)

      @users = User.order(:last_name)
      @companies = Company.ordered_by_name
      @clients = Client.ordered_alphabetically
    end
  end
end
