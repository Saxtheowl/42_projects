# frozen_string_literal: true

class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update]

  def index
    @clients = if params[:order] == 'company'
                 Client.ordered_by_company
               else
                 Client.ordered_alphabetically
               end
    @clients = @clients.includes(:company, :user)
  end

  def show
    @projects = @client.projects
    @activity_logs = ActivityLog.where(trackable: @client).by_date.limit(20)
  end

  def new
    @client = Client.new
    @companies = Company.ordered_by_name
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user

    if @client.save
      log_activity('created_client', @client, @client.full_name)
      redirect_to @client, notice: 'Client created successfully.'
    else
      @companies = Company.ordered_by_name
      render :new
    end
  end

  def edit
    @companies = Company.ordered_by_name
  end

  def update
    if @client.update(client_params)
      log_activity('updated_client', @client, @client.full_name)
      redirect_to @client, notice: 'Client updated successfully.'
    else
      @companies = Company.ordered_by_name
      render :edit
    end
  end

  def import
    if params[:file].present?
      Client.import_from_csv(params[:file], current_user)
      log_activity('imported_clients', nil, 'CSV import')
      redirect_to clients_path, notice: 'Clients imported successfully.'
    else
      redirect_to clients_path, alert: 'Please select a CSV file.'
    end
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:first_name, :last_name, :email, :phone, :position, :company_id)
  end
end
