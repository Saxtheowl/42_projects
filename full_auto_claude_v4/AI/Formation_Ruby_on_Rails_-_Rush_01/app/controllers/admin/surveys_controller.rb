# frozen_string_literal: true

module Admin
  class SurveysController < BaseController
    before_action :set_survey, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :export_results, :export_emails]

    def index
      @surveys = Survey.includes(:user).order(created_at: :desc)
    end

    def show
      @responses_count = @survey.survey_responses.count
    end

    def new
      @survey = Survey.new
      @survey.survey_questions.build
      @users = User.order(:last_name)
    end

    def create
      @survey = Survey.new(survey_params)

      if @survey.save
        log_activity('admin_created_survey', @survey, @survey.title)
        redirect_to admin_survey_path(@survey), notice: 'Survey created successfully.'
      else
        @users = User.order(:last_name)
        render :new
      end
    end

    def edit
      @survey.survey_questions.build if @survey.survey_questions.empty?
      @users = User.order(:last_name)
    end

    def update
      if @survey.update(survey_params)
        log_activity('admin_updated_survey', @survey, @survey.title)
        redirect_to admin_survey_path(@survey), notice: 'Survey updated successfully.'
      else
        @users = User.order(:last_name)
        render :edit
      end
    end

    def destroy
      @survey.destroy
      log_activity('admin_deleted_survey', nil, @survey.title)
      redirect_to admin_surveys_path, notice: 'Survey deleted successfully.'
    end

    def publish
      @survey.publish!
      log_activity('admin_published_survey', @survey, @survey.title)
      redirect_to admin_survey_path(@survey), notice: 'Survey published successfully.'
    end

    def unpublish
      @survey.unpublish!
      log_activity('admin_unpublished_survey', @survey, @survey.title)
      redirect_to admin_survey_path(@survey), notice: 'Survey unpublished successfully.'
    end

    def import
      if params[:file].present?
        Survey.import_from_csv(params[:file], current_user)
        log_activity('admin_imported_surveys', nil, 'CSV import')
        redirect_to admin_surveys_path, notice: 'Surveys imported successfully.'
      else
        redirect_to admin_surveys_path, alert: 'Please select a CSV file.'
      end
    end

    def export_results
      send_data @survey.results_to_csv, filename: "survey_#{@survey.id}_results.csv"
    end

    def export_emails
      send_data @survey.collected_emails_to_csv, filename: "survey_#{@survey.id}_emails.csv"
    end

    private

    def set_survey
      @survey = Survey.find(params[:id])
    end

    def survey_params
      params.require(:survey).permit(:title, :intro, :thank_you, :published, :user_id,
                                     survey_questions_attributes: [:id, :question, :_destroy])
    end
  end
end
