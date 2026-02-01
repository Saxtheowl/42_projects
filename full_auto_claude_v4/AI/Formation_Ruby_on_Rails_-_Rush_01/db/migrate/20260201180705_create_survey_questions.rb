class CreateSurveyQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_questions do |t|
      t.references :survey, foreign_key: true
      t.string :question

      t.timestamps
    end
  end
end
