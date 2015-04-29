class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.belongs_to :user

      t.string :name
      t.string :purpose
      t.text :description

      t.timestamps
    end
  end
end
