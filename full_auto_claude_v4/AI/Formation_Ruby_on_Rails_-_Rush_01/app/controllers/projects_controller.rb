# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create!, only: [:new, :create]

  def index
    @projects = Project.includes(:client, :user).order(created_at: :desc)
  end

  def show
    @quotes = @project.quotes
    @orders = @project.orders
    @invoices = @project.invoices
    @activity_logs = ActivityLog.where(trackable: @project).by_date.limit(20)
  end

  def new
    @project = Project.new
    @clients = Client.ordered_alphabetically
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user

    if @project.save
      log_activity('created_project', @project, @project.name)
      redirect_to @project, notice: 'Project created successfully.'
    else
      @clients = Client.ordered_alphabetically
      render :new
    end
  end

  def edit
    @clients = Client.ordered_alphabetically
  end

  def update
    if @project.update(project_params)
      log_activity('updated_project', @project, @project.name)
      redirect_to @project, notice: 'Project updated successfully.'
    else
      @clients = Client.ordered_alphabetically
      render :edit
    end
  end

  def destroy
    @project.destroy
    log_activity('deleted_project', nil, @project.name)
    redirect_to projects_path, notice: 'Project deleted successfully.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :client_id)
  end

  def authorize_create!
    redirect_to projects_path, alert: 'Only managers can create projects.' unless current_user.can_create_project?
  end
end
