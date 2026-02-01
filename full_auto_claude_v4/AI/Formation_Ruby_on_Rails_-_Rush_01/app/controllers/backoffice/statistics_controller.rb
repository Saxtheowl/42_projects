# frozen_string_literal: true

module Backoffice
  class StatisticsController < BaseController
    def index
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 3.months.ago.to_date
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    end

    def by_client
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 3.months.ago.to_date
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
      @client = Client.find(params[:client_id]) if params[:client_id].present?
      @clients = Client.ordered_alphabetically

      if @client
        @profit_data = calculate_weekly_profit_for_client(@client, @start_date, @end_date)
        @orders_data = calculate_weekly_orders_for_client(@client, @start_date, @end_date)
      end
    end

    def by_company
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 3.months.ago.to_date
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
      @company = Company.find(params[:company_id]) if params[:company_id].present?
      @companies = Company.ordered_by_name

      if @company
        @profit_data = calculate_weekly_profit_for_company(@company, @start_date, @end_date)
        @orders_data = calculate_weekly_orders_for_company(@company, @start_date, @end_date)
      end
    end

    def global
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 3.months.ago.to_date
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

      @profit_data = calculate_weekly_profit_global(@start_date, @end_date)
      @orders_data = calculate_weekly_orders_global(@start_date, @end_date)
    end

    private

    def calculate_weekly_profit_for_client(client, start_date, end_date)
      project_ids = client.projects.pluck(:id)
      calculate_weekly_profit(project_ids, start_date, end_date)
    end

    def calculate_weekly_profit_for_company(company, start_date, end_date)
      client_ids = company.clients.pluck(:id)
      project_ids = Project.where(client_id: client_ids).pluck(:id)
      calculate_weekly_profit(project_ids, start_date, end_date)
    end

    def calculate_weekly_profit_global(start_date, end_date)
      project_ids = Project.pluck(:id)
      calculate_weekly_profit(project_ids, start_date, end_date)
    end

    def calculate_weekly_profit(project_ids, start_date, end_date)
      weeks = []
      current = start_date.beginning_of_week
      end_week = end_date.end_of_week

      result = { weeks: [], profit: [] }

      current.step(end_week, 7).each do |week_start|
        week_end = week_start + 6.days
        result[:weeks] << week_start.strftime('%Y-%m-%d')

        revenue = Invoice.where(project_id: project_ids, invoice_type: 'outgoing')
                         .where(created_at: week_start..week_end)
                         .sum(:total)
        expenses = Invoice.where(project_id: project_ids, invoice_type: 'incoming')
                          .where(created_at: week_start..week_end)
                          .sum(:total)
        result[:profit] << (revenue - expenses).to_f
      end

      result
    end

    def calculate_weekly_orders_for_client(client, start_date, end_date)
      project_ids = client.projects.pluck(:id)
      calculate_weekly_orders(project_ids, start_date, end_date)
    end

    def calculate_weekly_orders_for_company(company, start_date, end_date)
      client_ids = company.clients.pluck(:id)
      project_ids = Project.where(client_id: client_ids).pluck(:id)
      calculate_weekly_orders(project_ids, start_date, end_date)
    end

    def calculate_weekly_orders_global(start_date, end_date)
      project_ids = Project.pluck(:id)
      calculate_weekly_orders(project_ids, start_date, end_date)
    end

    def calculate_weekly_orders(project_ids, start_date, end_date)
      current = start_date.beginning_of_week
      end_week = end_date.end_of_week

      result = { weeks: [], orders: [] }

      current.step(end_week, 7).each do |week_start|
        week_end = week_start + 6.days
        result[:weeks] << week_start.strftime('%Y-%m-%d')

        orders_total = Order.where(project_id: project_ids)
                            .where(created_at: week_start..week_end)
                            .sum(:total)
        result[:orders] << orders_total.to_f
      end

      result
    end
  end
end
