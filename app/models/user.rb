class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :ownerships
  has_many :images, through: :ownerships, dependent: :destroy

  has_many :folders, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       format: { without: /\s/ }

  after_create :create_basic_folders
  before_save { |user| user.username = user.username.capitalize }

  private
    def create_basic_folders
      Folder.new(name: "Main", user_id: self.id, purpose: "main").save
      Folder.new(name: "Share", user_id: self.id, purpose: "share").save
      Folder.new(name: "Trash", user_id: self.id, purpose: "trash").save
    end
end
