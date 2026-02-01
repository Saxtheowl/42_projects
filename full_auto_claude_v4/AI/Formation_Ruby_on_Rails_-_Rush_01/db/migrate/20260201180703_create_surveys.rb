class CreateSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.string :title
      t.text :intro
      t.text :thank_you
      t.references :user, foreign_key: true
      t.boolean :published

      t.timestamps
    end
  end
end
