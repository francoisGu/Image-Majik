class Folder < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :images, dependent: :destroy

  validates :name, presence: true
end
