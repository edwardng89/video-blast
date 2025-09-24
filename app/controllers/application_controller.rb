##
# Base Level controller
class ApplicationController < ActionController::Base
    def after_sign_in_path_for(resource)
        if resource.respond_to?(:admin?) && resource.admin?
            admin_root_path
        else
            root_path
        end
    end

    def after_sign_in_path_for(resource)
        resource.admin? ? admin_root_path : root_path
    end
end
