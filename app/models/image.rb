class Image < ActiveRecord::Base
  has_and_belongs_to_many :folders
  has_many :ownerships
  has_many :users, through: :ownerships, dependent: :destroy
  has_one :version, dependent: :destroy

  mount_uploader :file, FileUploader

  validates :name, presence: true
  validates :file, presence: true
  #validates :version, presence: true
end