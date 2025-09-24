# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  layout "public"

  def new
    @user = User.new
    super
  end

  # Optional: if you want to set defaults *explicitly* on create
  def create
    build_resource(sign_up_params)
    resource.role ||= "user"

    if resource.save
      sign_up(resource_name, resource)
      redirect_to root_path, notice: "Welcome to VideoBlast!"
    else
      clean_up_passwords resource
      set_minimum_password_length
      @user = resource
      render :new, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :first_name, :last_name,
      :address_line_1, :address_line_2,
      :suburb, :state, :postcode,
      :email, :password, :password_confirmation,
      :role # permitted if you use hidden field; harmless otherwise
    )
  end
end
