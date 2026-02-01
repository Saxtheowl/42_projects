class AddAvatarToBrands < ActiveRecord::Migration[5.2]
  def change
    add_column :brands, :avatar, :string
  end
end
