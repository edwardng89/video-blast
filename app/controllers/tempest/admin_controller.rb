class Tempest::AdminController < ApplicationController
  include LabelHelper
  include ApplicationHelper

  protect_from_forgery with: :exception, prepend: true # with: anything will do, note `prepend: true`!
  check_authorization unless: :devise_controller?

  skip_authorization_check only: %i[cleanup_dropzone_upload destroy_uploads action_modal]

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :create_settings

  before_action :log_requests





  ##
  # Setup attributes for checking within each action
  before_action except: :destroy do
    # If we haven't defined a mvi_permitted_attributes method then nothing to do
    if current_ability.respond_to?(:mvi_permitted_attributes)
      # If we have an instance variable for the controller (FIXME: would be good to use CanCan options) use
      # that record otherwise use the class
      obj = instance_variable_get("@#{controller_name.singularize}") ||
        controller_name.singularize.camelize.safe_constantize
      act = @override_action || action_name.to_sym # FIXME: need to work out how to handle non CRUD
      @cancancan_attributes = current_ability.mvi_permitted_attributes(act, obj)
      # if not read then also add read attributes
      @read_attributes = if %i[read show index].include?(act)
                           @cancancan_attributes
                         else
                           current_ability.mvi_permitted_attributes(:read, obj)
                         end
      @combined_attributes = if @read_attributes.nil? && @cancancan_attributes.nil?
                               nil
                             elsif @read_attributes.nil?
                               @cancancan_attributes
                             elsif @cancancan_attributes.nil?
                               @read_attributes
                             else
                               (@cancancan_attributes | @read_attributes)
                             end
    end
  end


  before_action :set__from_subdomain

  def set__from_subdomain
    _path = request.subdomains[0] # use lvh.me locally and add to config.hosts in development.rb

    # To handle different naming of sub domain column
    sub_domain_column = (.column_names & %w[subdomain sub_domain])&.first
    return unless sub_domain_column.present?

    @subdomain_ = .find_by("#{sub_domain_column}": _path)
    return unless @subdomain_

    session[:current__id] = @subdomain_&.id
  end


  ##
  # Logs the start of any request made
  def log_requests
    return unless Rails.env.production?

    logger = Rails.logger

    s = "Started: #{request.request_method} - #{request.path_info}"
    s << " | User_ID: #{current_user.id}" if current_user.present?
    s << " | Current_User: #{current_user.to_s}" if current_user.present?
    s << " | Parameters: #{request.filtered_parameters}" if request.filtered_parameters.present?
    s << " | User_Agent: #{request.user_agent}" if request.user_agent.present?
    s << " | Referer: #{request.referer}" if request.referer.present?
    s << " | User_IP: #{request.remote_ip}" if request.remote_ip.present?

    logger.info s
  end

  ##
  # Adds the current user into the payload for lograge output in greylog
  # @return [Hash]
  def append_info_to_payload(payload)
    return unless Rails.env.production?

    super
    payload[:uid] = current_user.id if current_user.present?
    payload[:current_user] = current_user.to_s if current_user.present?
    payload[:parameters] = request.filtered_parameters if request.filtered_parameters.present?
    payload[:referer] = request.referer if request.referer.present?
    payload[:user_agent] = request.user_agent if request.user_agent.present?
    payload[:user_ip] = request.remote_ip if request.remote_ip.present?
    payload[:request_ip] = request.ip if request.ip.present?
  end

  ##
  # create_settings when none exist
  def create_settings
    if can?(:manage, Setting)
      Setting.create if Setting.all.first.nil?
    end
  end


  before_action do
    @quick_edit = true
  end

  before_action do
    if ENV['AWS_REGION'].present?
      @presigner = Aws::S3::Presigner.new
    end
  end

  before_action do
    if current_user && can?(:manage, :all)
      Rack::MiniProfiler.authorize_request
    end
  end

  ##
  # If not an XHR request store the back and current url in session
  # FIXME: believe this should be avoiding not GET rather than rely on action names
  before_action except: [:create, :update, :destroy] do
    if !request.xhr?
      if session[:current_url] != request.path
        session[:back_url] = session[:current_url]
        session[:current_url] = request.path
      end
    end
  end

  # NOTE: Uncomment this if mvi deployment is used
  # Set the last_accessed for auto shutdown tracking
  # before_action do
  #   MviDeployment::System.set_last_accessed if Rails.env.production?
  # end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  ## Builds session of breadcrumbs starting from Index screens, resetting each time
  # a return to the index screen
before_action except: %i[create update destroy], unless: :devise_controller? do
  session[:breadcrumbs] = [] if action_name == 'index' && !request.xhr?

  if !request.xhr? && (request.format.to_s == 'text/html') && session[:breadcrumbs].present?
    session[:breadcrumbs].each do |crumb|
      add_breadcrumb crumb['crumb'].to_s.truncate(25), crumb['path']
    end
  end

  if !request.xhr? && (session[:current_url] != request.path) && (request.format.to_s == 'text/html')
    session[:back_url] = session[:current_url]
    session[:current_url] = request.path
  end
end

after_action except: %i[create update destroy], unless: :devise_controller? do
  session[:breadcrumbs] = [] unless session[:breadcrumbs].present?
  if !request.xhr? && (request.format.to_s == 'text/html') && @title.present?
    if action_name == 'index'
      session[:breadcrumbs] = [{ path: request.path, crumb: @title }]
    else
      if session[:breadcrumbs].map { |a| a['crumb'] }.include?(@title)
        index = session[:breadcrumbs].index { |x| x['crumb'] == @title }
        session[:breadcrumbs].delete_if.with_index { |num, idx| idx > index }
      else
        session[:breadcrumbs].push({ path: request.path, crumb: @title })
      end
    end
  end
end



  def destroy_common(record, path=nil)
    if record.destroy
      success_text = "#{record.class.model_name.human} was successfully removed."
      if path.present? && !request.xhr?
        flash[:notice] = success_text
        redirect_to path
      else
        render json: ['notice', success_text], status: :ok
      end
    else
      if path.present? && !request.xhr?
        flash[:error] = record.errors
        redirect_to path
      else
        render json: { 'error': record.errors }, status: :unprocessable_entity
      end
    end
  end



  ##
  # Deletes dropzone uploads
  def cleanup_dropzone_upload
    associated_class = params['attribute_param'].scan(/\[(.*)\]/).flatten.first.gsub('_attributes', '')

    records =
      (params['class_name'].titleize.tr(' ', '').constantize)
        .find_by(id: params['record_id'])
        .send(associated_class)
        .map do |a|
          if a.file.identifier ==
               (
                 params['record_name'].gsub(' ', '_') &&
                   a.created_at.to_date == Date.current
               )
            { id: a.id, name: a.file.identifier }
      end
    end
    records = records.reject(&:nil?)

    success = Attachment.find(records.last[:id]).destroy
    render json: { success: success }
  end

  ##
  # deletes the uploaded file though dropzone & clears the display
  def destroy_uploads
    @file_id = params['file_id']
    params['record_class'].constantize.find_by(id: @file_id).destroy
    respond_to do |format|
      format.js { render template: "/application/destroy_uploads" }
    end
  end

  private



    ##
    # Set a store for a controller action
    # @param store_name (String)
    def fetch_store(store_name, extra_ignored_params = nil)
      if params[:commit] == 'Clear'
        $redis.set(store_name, {}.to_json)
      else
        action_cache = $redis.get(store_name)

        if action_cache.present?
          action_cache = JSON.parse($redis.get(store_name).gsub('=>', ':'))
          params.merge!(action_cache.merge!(params.dup.to_unsafe_h))
        end
        params[:page] = 1 if params[:page].blank?
        ignored_params = %w[controller action sort query format page]
        ignored_params += extra_ignored_params if extra_ignored_params.present?
        saved_params =
          params.dup.to_unsafe_h.delete_if { |k, v| ignored_params.include? k }
        $redis.set(store_name, saved_params.to_json)
      end
    end

    # There is always a Home crumb
    # FIXME: Need control over this in Tempest as it may be referred to as Home or Dashboard or something else
    # FIXME: If we aren't going to use this anymore (not convinced we should unless we are confident all users
    # understand how to get to home/dashboard) then lets remove
    def set_base_crumb
      add_breadcrumb controller_label('Home'), root_url
    end

    # If the controller has an index action, we can automagically generate a crumb
    def set_controller_crumb
      if controller_name != 'home' and respond_to?("admin_#{controller_name}_index_path")
        add_breadcrumb controller_label, send("admin_#{controller_name}_index_path")
      elsif controller_name != 'home' and respond_to?("admin_#{controller_name}_path")
        add_breadcrumb controller_label, send("admin_#{controller_name}_path")
      end
    end

    # CRUD actions have standard crumbs that we can magic into existance
    def self.crud_crumbs(actions=[])
      actions.each do |crud_action|
        crumb_method = "crumb_for_#{crud_action}".to_sym

        before_action crumb_method, only: [crud_action.to_sym]
      end
    end

    def crumb_for_index
      name = controller_name.humanize.titleize.pluralize
      add_breadcrumb "All #{name}"
    end

    def crumb_for_new
      name = controller_name.humanize.titleize.singularize
      add_breadcrumb "New #{name}"
    end

    def crumb_for_edit
      object = send(controller_name.singularize)
      add_breadcrumb "Edit #{object.name}"
    end

    def crumb_for_show
      object = send(controller_name.singularize)
      add_breadcrumb "#{object.name}"
    end

    ##
    # method to return accessible url to private files within s3
    # @param key[String]
    # @return [String]
    def s3_url(key)
      @presigner.presigned_url(:get_object, bucket: ENV['S3_BUCKET'], key: key,
                               expires_in: 60.minute.to_i).to_s
    end

    ##
    # Renders the content of the action button modal before opening it
    def action_modal
      @source_model = params[:source_model]

      respond_to do |format|
        format.js { render template: '/application/action_modal' }
      end
    end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password,
                                                         :password_confirmation, :role])
    end

    ##
    # Take the permitted params for the action and combine with attributes defined in the controller to
    # eliminate those the current user doesn't have access to
    #
    # @param record (Object)
    # @param klass (Class)
    # @param full_attributes (Array)
    # @return (Array)
    def strong_accessible_params(record, klass, full_attributes)
      # If we haven't defined a mvi_permitted_attributes method then simply return full_attributes
      return full_attributes unless current_ability.respond_to?(:mvi_permitted_attributes)
      # Params should be the same but can't guarantee haven't setup different rules or user doesn't have access
      permitted_params = params[:id].present? ? [:update, record] : [:create, klass]
      cancancan_attributes = current_ability.mvi_permitted_attributes(*permitted_params)
      # If there is no restriction then return full_attributes
      return full_attributes if cancancan_attributes.nil?

      # Attempt here to avoid relying on all columns & submittable attributes
      cancancan_all_attributes = klass.column_names.map(&:to_sym) - Array(klass.primary_key&.to_sym)
      # Convert any association attributes back into having the _id suffix (FIXME: missing has_many)
      cancancan_attributes.map! do |a|
        id_attribute = "#{a}_id".to_sym
        cancancan_all_attributes.include?(id_attribute) ? id_attribute : a
      end
      inaccessible_attributes = cancancan_all_attributes - cancancan_attributes
      (full_attributes - inaccessible_attributes)
    end
end
