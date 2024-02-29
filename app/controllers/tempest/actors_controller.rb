class Tempest::ActorsController < AdminController
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource
  respond_to :html
  has_scope :query

  decorates_assigned :actors, :actor

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Actors'

    @actors = apply_scopes(@actors)
    respond_with(@actors) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @actors = @actors.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:actors])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @actors = Actor.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @actors = @actors
                  .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @actors.compact
      end
      format.js do
        @actors = @actors.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:actors])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @actors
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @actor

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Actor'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@actor}"

    respond_to do |format|
      if @actor.save
        format.html do
          if request.xhr?
            row_partial = actor_params[:alt_list].present? ? actor_params[:alt_list] : 'actor'
            render partial: row_partial, locals: { "#{row_partial}": @actor }, status: 200
          else

            redirect_to edit_admin_actor_path(@actor)

          end
        end
        format.json do
          render json: { 'record_id': @actor&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Actor'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @actor&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@actor}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@actor}"

    respond_to do |format|
      if @actor.update(actor_params)
        format.html do
          if request.xhr?
            row_partial = actor_params[:alt_list].present? ? actor_params[:alt_list] : 'actor'
            render partial: row_partial, locals: { "#{row_partial}": @actor }, status: 200
          else

            redirect_to edit_admin_actor_path(@actor), notice: 'Actor was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @actor&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@actor}"
            render action: :edit
          end
        end
        format.json { render json: @actor.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@actor, admin_actors_path)
  end

  # -- custom_actions_starts --
  # -- custom_actions_ends --

  private

  def index_setup
    @allow_create = true
    @full_edit_create = false
    @default_limit = 25
    @allow_filter = false
    @pdf_button = false
    @copy_button = false
    @csv_button = false
    @xls_button = true
    @print_button = false
    @main_list_screen = true
    @icon = ''
    @show_buttons = @pdf_button || @copy_button || @csv_button || @xls_button || @print_button

    ## nested model setup starts ##
    ## nested model setup ends ##
  end

  def actor_params
    full_attributes = [
      :birth_date,
      :first_name,
      :gender,
      :last_name,
      { movie_actor_ids: [] },
      :alt_list
    ]

    params.require(:actor)
          .permit(*strong_accessible_params(@actor,
                                            Actor,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
