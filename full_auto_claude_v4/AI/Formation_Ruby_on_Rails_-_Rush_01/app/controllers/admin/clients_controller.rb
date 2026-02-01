# frozen_string_literal: true

module Admin
  class ClientsController < BaseController
    before_action :set_client, only: [:show, :edit, :update, :destroy]

    def index
      @clients = Client.includes(:company, :user).ordered_alphabetically
    end

    def show
    end

    def new
      @client = Client.new
      @companies = Company.ordered_by_name
      @users = User.order(:last_name)
    end

    def create
      @client = Client.new(client_params)

      if @client.save
        log_activity('admin_created_client', @client, @client.full_name)
        redirect_to admin_client_path(@client), notice: 'Client created successfully.'
      else
        @companies = Company.ordered_by_name
        @users = User.order(:last_name)
        render :new
      end
    end

    def edit
      @companies = Company.ordered_by_name
      @users = User.order(:last_name)
    end

    def update
      if @client.update(client_params)
        log_activity('admin_updated_client', @client, @client.full_name)
        redirect_to admin_client_path(@client), notice: 'Client updated successfully.'
      else
        @companies = Company.ordered_by_name
        @users = User.order(:last_name)
        render :edit
      end
    end

    def destroy
      @client.destroy
      log_activity('admin_deleted_client', nil, @client.full_name)
      redirect_to admin_clients_path, notice: 'Client deleted successfully.'
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
