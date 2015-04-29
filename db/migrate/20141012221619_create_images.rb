class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
     # t.integer :version
      t.string :file

      t.timestamps
    end
  end
end
