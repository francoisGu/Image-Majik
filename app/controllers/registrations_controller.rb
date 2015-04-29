class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    my_folders_path
  end
end
