# frozen_string_literal: true

class InMailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_in_mail, only: [:show, :pdf]

  def inbox
    @in_mails = current_user.received_mails.by_date
  end

  def outbox
    @in_mails = current_user.sent_mails.by_date
  end

  def show
    @in_mail.mark_as_read! if @in_mail.recipient == current_user
  end

  def new
    @in_mail = InMail.new
    @in_mail.recipient_id = params[:recipient_id] if params[:recipient_id]
    @users = User.where.not(id: current_user.id)
  end

  def create
    @in_mail = InMail.new(in_mail_params)
    @in_mail.sender = current_user
    @in_mail.read = false

    if @in_mail.save
      log_activity('sent_mail', @in_mail, "To: #{@in_mail.recipient&.full_name}")
      redirect_to outbox_in_mails_path, notice: 'Message sent successfully.'
    else
      @users = User.where.not(id: current_user.id)
      render :new
    end
  end

  def contacts
    @users = User.where.not(id: current_user.id).order(:last_name, :first_name)
  end

  def pdf
    pdf = Prawn::Document.new
    pdf.text "From: #{@in_mail.sender.full_name}", size: 12
    pdf.text "To: #{@in_mail.recipient&.full_name}", size: 12
    pdf.text "Date: #{@in_mail.created_at.strftime('%Y-%m-%d %H:%M')}", size: 12
    pdf.text "Subject: #{@in_mail.subject}", size: 14, style: :bold
    pdf.move_down 20
    pdf.text @in_mail.body

    send_data pdf.render,
              filename: "mail_#{@in_mail.id}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  private

  def set_in_mail
    @in_mail = InMail.find(params[:id])
    unless @in_mail.sender == current_user || @in_mail.recipient == current_user || current_user.can_read_all_mails?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def in_mail_params
    params.require(:in_mail).permit(:recipient_id, :subject, :body)
  end
end
