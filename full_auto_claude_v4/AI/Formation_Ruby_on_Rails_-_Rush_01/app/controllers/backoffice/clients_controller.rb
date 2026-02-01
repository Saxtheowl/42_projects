# frozen_string_literal: true

module Backoffice
  class ClientsController < BaseController
    before_action :set_client, only: [:show, :edit, :update, :destroy]

    def index
      @clients = Client.includes(:company, :user).ordered_alphabetically
    end

    def show
      @activity_logs = ActivityLog.where(trackable: @client).by_date.limit(20)
    end

    def edit
      @companies = Company.ordered_by_name
      @users = User.order(:last_name)
    end

    def update
      if @client.update(client_params)
        log_activity('manager_updated_client', @client, @client.full_name)
        redirect_to backoffice_client_path(@client), notice: 'Client updated successfully.'
      else
        @companies = Company.ordered_by_name
        @users = User.order(:last_name)
        render :edit
      end
    end

    def destroy
      @client.destroy
      log_activity('manager_deleted_client', nil, @client.full_name)
      redirect_to backoffice_clients_path, notice: 'Client deleted successfully.'
    end

    def export
      send_data Client.to_csv, filename: "clients_#{Date.today}.csv"
    end

    private

    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:first_name, :last_name, :email, :phone, :position, :company_id, :user_id)
    end
  end
end
