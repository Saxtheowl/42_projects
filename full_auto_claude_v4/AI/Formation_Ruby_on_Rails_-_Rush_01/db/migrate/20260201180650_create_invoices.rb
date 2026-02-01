class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.references :project, foreign_key: true
      t.string :invoice_type
      t.text :intro
      t.decimal :total
      t.string :status

      t.timestamps
    end
  end
end
