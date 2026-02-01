# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_order, only: [:show, :edit, :update, :destroy, :pdf]

  def index
    @orders = @project.orders
  end

  def show
  end

  def new
    @order = @project.orders.build
    @order.line_items.build
  end

  def create
    @order = @project.orders.build(order_params)

    if @order.save
      @order.update_total!
      log_activity('created_order', @order, "Project: #{@project.name}")
      redirect_to project_order_path(@project, @order), notice: 'Order created successfully.'
    else
      render :new
    end
  end

  def edit
    @order.line_items.build if @order.line_items.empty?
  end

  def update
    if @order.update(order_params)
      @order.update_total!
      log_activity('updated_order', @order, "Project: #{@project.name}")
      redirect_to project_order_path(@project, @order), notice: 'Order updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @order.destroy
    log_activity('deleted_order', nil, "Project: #{@project.name}")
    redirect_to project_orders_path(@project), notice: 'Order deleted successfully.'
  end

  def pdf
    pdf = generate_document_pdf(@order, 'Order')
    send_data pdf.render,
              filename: "order_#{@order.id}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_order
    @order = @project.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:intro, :status, line_items_attributes: [:id, :description, :price, :quantity, :_destroy])
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
