class CreateVersions < ActiveRecord::Migration
  def change
     create_table :versions do |t|
      t.belongs_to :image
      t.integer :pre_version
      t.string :version_identify
      t.integer :root_id

      
 
      t.timestamps
    end
  end
end
