# frozen_string_literal: true

class SurveysController < ApplicationController
  before_action :authenticate_user!, except: [:public_show, :respond]
  before_action :set_survey, only: [:show, :edit, :update, :destroy]

  def index
    @surveys = current_user.surveys
  end

  def show
    @responses_count = @survey.survey_responses.count
  end

  def new
    @survey = Survey.new
    @survey.survey_questions.build
  end

  def create
    @survey = current_user.surveys.build(survey_params)

    if @survey.save
      log_activity('created_survey', @survey, @survey.title)
      redirect_to @survey, notice: 'Survey created successfully.'
    else
      render :new
    end
  end

  def edit
    @survey.survey_questions.build if @survey.survey_questions.empty?
  end

  def update
    if @survey.update(survey_params)
      log_activity('updated_survey', @survey, @survey.title)
      redirect_to @survey, notice: 'Survey updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @survey.destroy
    log_activity('deleted_survey', nil, @survey.title)
    redirect_to surveys_path, notice: 'Survey deleted successfully.'
  end

  def public_show
    @survey = Survey.published.find(params[:id])
    @response = SurveyResponse.new
    @response.survey_answers.build(@survey.survey_questions.map { |q| { survey_question_id: q.id } })
  end

  def respond
    @survey = Survey.published.find(params[:id])
    @response = @survey.survey_responses.build(response_params)
    @response.user = current_user if user_signed_in?

    if @response.save
      redirect_to thank_you_survey_path(@survey), notice: 'Thank you for your response!'
    else
      render :public_show
    end
  end

  def thank_you
    @survey = Survey.find(params[:id])
  end

  private

  def set_survey
    @survey = current_user.surveys.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:title, :intro, :thank_you, :published,
                                   survey_questions_attributes: [:id, :question, :_destroy])
  end

  def response_params
    params.require(:survey_response).permit(:email, survey_answers_attributes: [:survey_question_id, :answer])
  end
end
