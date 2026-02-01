class CreateInMails < ActiveRecord::Migration[5.2]
  def change
    create_table :in_mails do |t|
      t.references :sender, foreign_key: { to_table: :users }
      t.references :recipient, foreign_key: { to_table: :users }
      t.string :subject
      t.text :body
      t.boolean :read

      t.timestamps
    end
  end
end
