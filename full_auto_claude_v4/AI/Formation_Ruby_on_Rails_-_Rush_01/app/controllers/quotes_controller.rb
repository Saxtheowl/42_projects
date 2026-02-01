# frozen_string_literal: true

class QuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :pdf]

  def index
    @quotes = @project.quotes
  end

  def show
  end

  def new
    @quote = @project.quotes.build
    @quote.line_items.build
  end

  def create
    @quote = @project.quotes.build(quote_params)

    if @quote.save
      @quote.update_total!
      log_activity('created_quote', @quote, "Project: #{@project.name}")
      redirect_to project_quote_path(@project, @quote), notice: 'Quote created successfully.'
    else
      render :new
    end
  end

  def edit
    @quote.line_items.build if @quote.line_items.empty?
  end

  def update
    if @quote.update(quote_params)
      @quote.update_total!
      log_activity('updated_quote', @quote, "Project: #{@project.name}")
      redirect_to project_quote_path(@project, @quote), notice: 'Quote updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @quote.destroy
    log_activity('deleted_quote', nil, "Project: #{@project.name}")
    redirect_to project_quotes_path(@project), notice: 'Quote deleted successfully.'
  end

  def pdf
    pdf = generate_document_pdf(@quote, 'Quote')
    send_data pdf.render,
              filename: "quote_#{@quote.id}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_quote
    @quote = @project.quotes.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:intro, :status, line_items_attributes: [:id, :description, :price, :quantity, :_destroy])
  end

  def generate_document_pdf(document, type)
    pdf = Prawn::Document.new
    pdf.text "#{type} ##{document.id}", size: 20, style: :bold
    pdf.move_down 10
    pdf.text "Client: #{document.client.full_name}", size: 12
    pdf.text "Company: #{document.client.company&.name}", size: 12
    pdf.text "Operator: #{document.user.full_name}", size: 12
    pdf.text "Date: #{document.created_at.strftime('%Y-%m-%d')}", size: 12
    pdf.move_down 20

    if document.intro.present?
      pdf.text 'Introduction:', style: :bold
      pdf.text ActionController::Base.helpers.strip_tags(document.intro)
      pdf.move_down 20
    end

    if document.line_items.any?
      data = [['Description', 'Price', 'Qty', 'Subtotal']]
      document.line_items.each do |item|
        data << [item.description, "#{item.price} EUR", item.quantity.to_s, "#{item.subtotal} EUR"]
      end
      data << ['', '', 'Total:', "#{document.total || document.calculate_total} EUR"]
      pdf.table(data, header: true, width: pdf.bounds.width)
    end

    pdf
  end
end
