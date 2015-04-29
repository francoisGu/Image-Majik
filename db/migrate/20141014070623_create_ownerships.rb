class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships, id: false do |t|
      t.belongs_to :user
      t.belongs_to :image

      t.boolean :is_owner

      t.timestamps
    end

    add_index :ownerships, :user_id
    add_index :ownerships, :image_id
  end
end
