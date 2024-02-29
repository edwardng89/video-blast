##
# Public Access Controller
class PublicController < ActionController::Base
  skip_authorization_check only: :status

  ##
  # Used for external monitoring
  def status
    commit = `git show --pretty=%H -q`.chomp
    render json: { migration: ActiveRecord::SchemaMigration.last.version,
                   commit:,
                   request_ip: request.remote_ip }
  end
end
