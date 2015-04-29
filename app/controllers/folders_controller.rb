class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :edit, :update, :destroy, :empty_trash,
                                    :check_folder_auth, :check_folder_type]
  before_action :check_folder_auth, only: [:show, :edit, :update, :destroy, :empty_trash]
  before_action :check_folder_type, only: [:edit, :update, :destroy]

  # Find all folders of current user.
  def my_folders
    @folders = Folder.where(user_id: current_user.id)
  end

  # GET /folders/1
  # GET /folders/1.json
  def show
  end

  # GET /folders/new
  def new
    @folder = Folder.new
  end

  # GET /folders/1/edit
  def edit
  end

  # POST /folders
  # POST /folders.json
  def create
    @folder = Folder.new(folder_params)
    @folder.user_id = current_user.id
    @folder.purpose = "album"

    @folder.save
    respond_to do |format|
      if @folder.save
        format.html { redirect_to my_folders_path, notice: 'Album was successfully created.' }
        format.json { render :show, status: :created, location: @folder }
      else
        format.html { render :new }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /folders/1
  # PATCH/PUT /folders/1.json
  def update
    @folder.update(folder_params)
    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to @folder, notice: 'Album was successfully updated.' }
        format.json { render :show, status: :ok, location: @folder }
      else
        format.html { render :edit }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folders/1
  # DELETE /folders/1.json
  def destroy
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to my_folders_path, notice: 'Album was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Destroy all files in trash.
  def empty_trash
    if @folder.purpose != "trash"
      flash[:alert] = "Sorry, you can not empty this folder."
    else
      @folder.images.each do |image|
        image.destroy
      end
      flash[:notice] = "Trash was successfully emptyed."
    end
    redirect_to folder_path(@folder)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def folder_params
      params.require(:folder).permit(:name)
    end

    # Check the user is the author of the folder
    def check_folder_auth
      if @folder.user_id != current_user.id
        flash[:alert] = "Sorry, you are not the author of this foldder."
        redirect_to my_folders_path
      end
    end

    # Check the folder is not "ablum" type
    def check_folder_type
      if @folder.purpose != "album"
        flash[:alert] = "Sorry, you can not edit this foldder."
        redirect_to my_folders_path
      end
    end
end
