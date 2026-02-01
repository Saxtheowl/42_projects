# frozen_string_literal: true

class SurveyQuestion < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers, dependent: :destroy

  validates :question, presence: true
end
