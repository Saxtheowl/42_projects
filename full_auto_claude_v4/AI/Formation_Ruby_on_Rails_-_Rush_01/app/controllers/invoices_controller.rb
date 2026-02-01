# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :pdf]

  def index
    @invoices = @project.invoices
  end

  def show
  end

  def new
    @invoice = @project.invoices.build
    @invoice.invoice_type = params[:type] || 'outgoing'
    @invoice.line_items.build
  end

  def create
    @invoice = @project.invoices.build(invoice_params)

    if @invoice.save
      @invoice.update_total!
      log_activity('created_invoice', @invoice, "Project: #{@project.name}, Type: #{@invoice.invoice_type}")
      redirect_to project_invoice_path(@project, @invoice), notice: 'Invoice created successfully.'
    else
      render :new
    end
  end

  def edit
    @invoice.line_items.build if @invoice.line_items.empty?
  end

  def update
    if @invoice.update(invoice_params)
      @invoice.update_total!
      log_activity('updated_invoice', @invoice, "Project: #{@project.name}")
      redirect_to project_invoice_path(@project, @invoice), notice: 'Invoice updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @invoice.destroy
    log_activity('deleted_invoice', nil, "Project: #{@project.name}")
    redirect_to project_invoices_path(@project), notice: 'Invoice deleted successfully.'
  end

  def pdf
    pdf = generate_document_pdf(@invoice, "Invoice (#{@invoice.invoice_type.capitalize})")
    send_data pdf.render,
              filename: "invoice_#{@invoice.id}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_invoice
    @invoice = @project.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:intro, :invoice_type, :status, line_items_attributes: [:id, :description, :price, :quantity, :_destroy])
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
