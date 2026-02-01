# frozen_string_literal: true

class SurveyResponse < ApplicationRecord
  belongs_to :survey
  belongs_to :user, optional: true
  has_many :survey_answers, dependent: :destroy

  accepts_nested_attributes_for :survey_answers

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
