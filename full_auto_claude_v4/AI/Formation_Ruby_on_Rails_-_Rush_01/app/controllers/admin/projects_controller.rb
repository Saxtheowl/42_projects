# frozen_string_literal: true

module Admin
  class ProjectsController < BaseController
    before_action :set_project, only: [:show, :edit, :update, :destroy]

    def index
      @projects = Project.includes(:client, :user).order(created_at: :desc)
    end

    def show
    end

    def new
      @project = Project.new
      @clients = Client.ordered_alphabetically
      @users = User.order(:last_name)
    end

    def create
      @project = Project.new(project_params)

      if @project.save
        log_activity('admin_created_project', @project, @project.name)
        redirect_to admin_project_path(@project), notice: 'Project created successfully.'
      else
        @clients = Client.ordered_alphabetically
        @users = User.order(:last_name)
        render :new
      end
    end

    def edit
      @clients = Client.ordered_alphabetically
      @users = User.order(:last_name)
    end

    def update
      if @project.update(project_params)
        log_activity('admin_updated_project', @project, @project.name)
        redirect_to admin_project_path(@project), notice: 'Project updated successfully.'
      else
        @clients = Client.ordered_alphabetically
        @users = User.order(:last_name)
        render :edit
      end
    end

    def destroy
      @project.destroy
      log_activity('admin_deleted_project', nil, @project.name)
      redirect_to admin_projects_path, notice: 'Project deleted successfully.'
    end

    private

    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :client_id, :user_id)
    end
  end
end
