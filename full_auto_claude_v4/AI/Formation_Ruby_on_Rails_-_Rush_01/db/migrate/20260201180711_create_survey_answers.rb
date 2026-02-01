class CreateSurveyAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_answers do |t|
      t.references :survey_response, foreign_key: true
      t.references :survey_question, foreign_key: true
      t.boolean :answer

      t.timestamps
    end
  end
end
