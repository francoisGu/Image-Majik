class Version < ActiveRecord::Base
  belongs_to :image
  #after_save :default_value

  # private def  default_value
  #   self.root_id =  self.id
  # end
end
