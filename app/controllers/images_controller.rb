class ImagesController < ApplicationController
  before_action :get_folder
  before_action :set_image, only: [:show, :edit, :update, :destroy, :move_to_trash, 
                                   :put_back, :share, :add_to_album, :download, :add_filter]
  before_action :check_image_auth, only: [:edit, :update, :share]
  before_action :check_main_album_folder, only: [:new, :create]

  # Define the algorithms of filters in a list.
  @@filters = [
      ['blue_shift', 3],
      ['charcoal'],
      ['flop'],
      ['frame'],
      ['motion_blur', 0, 10, 30],
      ['normalize'],
      ['oil_paint', 6],
      ['posterize'],
      ['quantize', 256, Magick::GRAYColorspace],
      ['rotate', 180],
      ['sepiatone']
    ]

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)
    #@image.version = 0
    @image.folders << @folder
    main_folder = current_user.folders.find_by(purpose: "main")
    @image.folders << main_folder if !@image.folders.include?(main_folder)
    @image.save
    Ownership.new(image_id: @image.id, user_id: current_user.id, is_owner: true).save

   new_version = Version.new(image: @image,  version_identify: '1')
    new_version.save    
    new_version.update(root_id: new_version.id)

    respond_to do |format|
      if @image.save
        format.html { redirect_to [@folder, @image], notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: [@folder, @image] }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to [@folder, @image], notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: [@folder, @image] }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    if Ownership.find_by(user_id: current_user.id, image_id: @image.id).is_owner
      @image.destroy
      versions = Version.where(pre_version: @image.version.id)
      versions.each do |version|
        version.pre_version = @image.version.pre_version
        version.save
      end
    else
      @image.folders.delete(@folder)
      @image.users.delete(current_user)
    end
    respond_to do |format|
      format.html { redirect_to @folder, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Image is moved from the current folder to the trash.
  def move_to_trash
    trash = Folder.find_by(user_id: current_user.id, purpose: "trash")
    @image.folders.delete(@folder)
    @image.folders << trash if @folder.purpose != "album"
    respond_to do |format|
      format.html { redirect_to @folder, notice: 'Image was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # Move the Image from trash to the main folder if current user is the author
  #   of this image, otherwise, move it to the share folder.
  def put_back
    if Ownership.find_by(user_id: current_user.id, image_id: @image.id).is_owner
      folder_to = Folder.find_by(user_id: current_user.id, purpose: "main")
    else
      folder_to = Folder.find_by(user_id: current_user.id, purpose: "share")
    end
    trash = Folder.find_by(user_id: current_user.id, purpose: "trash")
    @image.folders.delete(trash)
    @image.folders << folder_to
    respond_to do |format|
      format.html { redirect_to @folder, notice: 'Image was successfully put back.' }
      format.json { head :no_content }
    end
  end

  # Image is shared to other user, so it will appear in the share folder of the user shared to.
  def share
    # Try to find the user.
    user_share = User.find_by(username: params[:user_share_to].capitalize)
    if !user_share.nil?
      # If we found the user.
      action = params[:commit]
      if action == "Add"
        share_add(user_share)
        message = 'Shared successfully.'
      elsif action == "Delete"
        share_delete(user_share)
        message = 'Deleted successfully.'
      end
      respond_to do |format|
        format.html { redirect_to edit_folder_image_path(@folder, @image), notice: message }
        format.json { head :no_content }
      end
    else
      # If user is not found.
      message = "Username doesn't exist."
      respond_to do |format|
        format.html { redirect_to edit_folder_image_path(@folder, @image), alert: message }
        format.json { head :no_content }
      end
    end
  end

  # Image is added to the album, so it will appear in the album.
  def add_to_album
    album_to = Folder.find(params[:album_to])
    if !@image.folders.include?(album_to)
      @image.folders << album_to
    end
    respond_to do |format|
      format.html { redirect_to edit_folder_image_path(@folder, @image), notice: 'Image was successfully added to album.' }
      format.json { head :no_content }
    end
  end

  # Image can be downloaded directly.
  def download
    send_file @image.file.path
  end

  # Create a new copy, Add filter to the Image.
  def add_filter
    require 'RMagick'
    # Add filter
    img = Magick::Image::read('public'+@image.file.url)[0]
    img = img.send(*@@filters[params[:filter_option].to_i])
    img.write('public/uploads/tmp/temp.jpg')

    # Add to database
    file = File.open('public/uploads/tmp/temp.jpg')
    new_image = Image.create(name:@image.name, file:file)
    main_folder = current_user.folders.find_by(purpose: "main")
    new_image.folders << main_folder if !new_image.folders.include?(main_folder)
    new_image.save
    Ownership.new(image_id: new_image.id, user_id: current_user.id, is_owner: true).save

   new_version = Version.new(
                                                                image: new_image, 
                                                                pre_version: @image.version.id, 
                                                                version_identify: get_identify(@image.version),
                                                                root_id: @image.version.root_id,
                                                        )
    new_version.save

    respond_to do |format|
      format.html { redirect_to folder_image_path(@folder, new_image), notice: 'Image was successfully added to album.' }
      format.json { head :no_content }
    end
  end

  private
    # Get the current user.
    def get_folder
      @folder = Folder.find(params[:folder_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = @folder.images.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:name, :file)
    end

    # Check the user is the author of the image
    def check_image_auth
      if !@image.ownerships.find_by(user_id: current_user.id).is_owner
        flash[:alert] = "Sorry, you are not the author of this image"
        redirect_to folder_images_path
      end
    end

    # Make sure the folder is main folder
    def check_main_album_folder
      if !@folder.purpose.in? ["main", "album"]
        flash[:alert] = "Sorry, you can not create new image in this folder"
        redirect_to folder_images_path
      end
    end

    def share_add(user)
      if Ownership.find_by(user_id: user.id, image_id: @image.id).nil?
        Ownership.new(user_id: user.id, image_id: @image.id, is_owner: false).save
        @image.folders << user.folders.find_by(purpose: "share")
      end
    end

    def share_delete(user)
      user.images.delete(@image)
      @image.folders.delete(user.folders.find_by(purpose: "share"))
    end

    def get_identify(pre_version)
      versions = Version.where(root_id: pre_version.root_id)
      count = 1
      versions.each do |v|
        per_identify = pre_version.version_identify
        match_value = v.version_identify[(per_identify.length+1),v.version_identify.length]
        if match_value && match_value.match(/[1-9]+/)
          count  = count +1
        end
      end
      version_identify = pre_version.version_identify+'_'+count.to_s
      return version_identify
    end
end