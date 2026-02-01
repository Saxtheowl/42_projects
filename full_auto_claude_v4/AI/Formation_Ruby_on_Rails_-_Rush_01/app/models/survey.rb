# frozen_string_literal: true

class Survey < ApplicationRecord
  belongs_to :user
  has_many :survey_questions, dependent: :destroy
  has_many :survey_responses, dependent: :destroy

  accepts_nested_attributes_for :survey_questions, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true

  scope :published, -> { where(published: true) }
  scope :drafts, -> { where(published: false) }

  def publish!
    update(published: true)
  end

  def unpublish!
    update(published: false)
  end

  def self.import_from_csv(file, user)
    require 'roo'
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1).map(&:downcase)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      survey = Survey.create(
        title: row['title'] || row['titre'],
        intro: row['intro'],
        thank_you: row['thank_you'] || row['remerciement'],
        user: user,
        published: false
      )

      questions = row['questions']&.split('|')
      questions&.each do |question|
        survey.survey_questions.create(question: question.strip)
      end
    end
  end

  def results_to_csv
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << ['Question', 'Yes Count', 'No Count', 'Yes %', 'No %']
      survey_questions.each do |question|
        yes_count = question.survey_answers.where(answer: true).count
        no_count = question.survey_answers.where(answer: false).count
        total = yes_count + no_count
        yes_pct = total > 0 ? (yes_count.to_f / total * 100).round(2) : 0
        no_pct = total > 0 ? (no_count.to_f / total * 100).round(2) : 0
        csv << [question.question, yes_count, no_count, "#{yes_pct}%", "#{no_pct}%"]
      end
    end
  end

  def collected_emails_to_csv
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << ['Email', 'Responded At']
      survey_responses.each do |response|
        csv << [response.email, response.created_at]
      end
    end
  end
end
