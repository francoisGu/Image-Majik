class CreateFoldersImages < ActiveRecord::Migration
  def change
    create_table :folders_images, id: false  do |t|
      t.belongs_to :folder
      t.belongs_to :image
    end

    add_index :folders_images, :folder_id
    add_index :folders_images, :image_id
  end
end
