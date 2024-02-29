##
# Overrides devise session controller to remove flash message only on login/logout action
class SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super
    flash.delete(:notice)
  end

  # DELETE /resource/sign_out
  def destroy
    super
    flash.delete(:notice)
  end

  after_action :unauthenticated

  protected

  def unauthenticated
    flash[:alert] = t("devise.failure.#{request.env['warden'].message}") unless request.env['warden'].message.blank?
  end
end
