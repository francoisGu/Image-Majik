class VersionsController < ApplicationController
  before_action :get_folder, only: [:show, :edit, :update, :destroy]
  before_action :get_image, only: [:show, :edit, :update, :destroy]
  before_action :set_version, only: [:show, :edit, :update, :destroy]

  def show
    version_images = Version.where(root_id: @version.root_id)
    @my_version_images = []
    version_images.each do |version|
      if version.image.users.include?(current_user)
        @my_version_images << version.image
      end
    end
  end

  def new
    @version = Version.new
    respond_with(@version)
  end

  def edit
  end

  def create
    @version = Version.new(version_params)
    @version.save
    respond_with(@version)
  end

  def update
    @version.update(version_params)
    respond_with(@version)
  end

  def destroy
    @version.destroy
    respond_with(@version)
  end

  private
    def get_folder
      @folder = Folder.find(params[:folder_id])
    end

    def get_image
      @image = @folder.images.find(params[:image_id])
    end

    def set_version
      @version = @image.version
    end

    def version_params
      params[:version]
    end
end
