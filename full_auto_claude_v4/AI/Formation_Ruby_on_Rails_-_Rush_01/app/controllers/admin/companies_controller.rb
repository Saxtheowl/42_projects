# frozen_string_literal: true

module Admin
  class CompaniesController < BaseController
    before_action :set_company, only: [:show, :edit, :update, :destroy]

    def index
      @companies = Company.ordered_by_name
    end

    def show
      @clients = @company.clients
    end

    def new
      @company = Company.new
    end

    def create
      @company = Company.new(company_params)

      if @company.save
        log_activity('admin_created_company', @company, @company.name)
        redirect_to admin_company_path(@company), notice: 'Company created successfully.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @company.update(company_params)
        log_activity('admin_updated_company', @company, @company.name)
        redirect_to admin_company_path(@company), notice: 'Company updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @company.destroy
      log_activity('admin_deleted_company', nil, @company.name)
      redirect_to admin_companies_path, notice: 'Company deleted successfully.'
    end

    private

    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :address, :phone, :email)
    end
  end
end
