# frozen_string_literal: true

module Admin
  class InMailsController < BaseController
    before_action :set_in_mail, only: [:show, :destroy]

    def index
      @in_mails = InMail.includes(:sender, :recipient).by_date
      @in_mails = @in_mails.where(sender_id: params[:user_id]).or(@in_mails.where(recipient_id: params[:user_id])) if params[:user_id].present?
      @in_mails = filter_by_group(@in_mails, params[:group]) if params[:group].present?
    end

    def show
    end

    def new
      @in_mail = InMail.new
      @users = User.order(:last_name)
      @groups = User::OPERATOR_GROUPS
    end

    def create
      if params[:send_to] == 'group' && params[:group].present?
        InMail.send_to_group(current_user, params[:group], in_mail_params[:subject], in_mail_params[:body])
        log_activity('admin_sent_group_mail', nil, "Group: #{params[:group]}")
        redirect_to admin_in_mails_path, notice: "Message sent to #{params[:group]} group."
      elsif params[:send_to] == 'all'
        InMail.send_to_all(current_user, in_mail_params[:subject], in_mail_params[:body])
        log_activity('admin_sent_all_mail', nil, 'All users')
        redirect_to admin_in_mails_path, notice: 'Message sent to all users.'
      else
        @in_mail = InMail.new(in_mail_params)
        @in_mail.sender = current_user
        @in_mail.read = false

        if @in_mail.save
          log_activity('admin_sent_mail', @in_mail, "To: #{@in_mail.recipient&.full_name}")
          redirect_to admin_in_mails_path, notice: 'Message sent successfully.'
        else
          @users = User.order(:last_name)
          @groups = User::OPERATOR_GROUPS
          render :new
        end
      end
    end

    def destroy
      @in_mail.destroy
      redirect_to admin_in_mails_path, notice: 'Message deleted successfully.'
    end

    def history
      @activity_logs = ActivityLog.where("action LIKE '%mail%'").by_date
      @activity_logs = @activity_logs.for_user(User.find(params[:user_id])) if params[:user_id].present?
      @activity_logs = filter_logs_by_group(@activity_logs, params[:group]) if params[:group].present?
    end

    private

    def set_in_mail
      @in_mail = InMail.find(params[:id])
    end

    def in_mail_params
      params.require(:in_mail).permit(:recipient_id, :subject, :body)
    end

    def filter_by_group(in_mails, group)
      user_ids = User.where(operator_group: group).pluck(:id)
      in_mails.where(sender_id: user_ids).or(in_mails.where(recipient_id: user_ids))
    end

    def filter_logs_by_group(logs, group)
      user_ids = User.where(operator_group: group).pluck(:id)
      logs.where(user_id: user_ids)
    end
  end
end
