class Tempest::OrderMovieCopiesController < AdminController
  has_scope :in_order, as: :sort, allow_blank: true, default: 'order'
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource
  respond_to :html
  has_scope :query

  decorates_assigned :order_movie_copies, :order_movie_copy

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Order Movie Copies'

    @order_movie_copies = apply_scopes(@order_movie_copies.includes(:order, :movie_copy))
    respond_with(@order_movie_copies) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @order_movie_copies = @order_movie_copies.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:order_movie_copies])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @order_movie_copies = OrderMovieCopy.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @order_movie_copies = @order_movie_copies
                              .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @order_movie_copies.compact
      end
      format.js do
        @order_movie_copies = @order_movie_copies.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:order_movie_copies])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @order_movie_copies
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @order_movie_copy

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Order Movie Copy'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@order_movie_copy}"

    respond_to do |format|
      if @order_movie_copy.save
        format.html do
          if request.xhr?
            row_partial = order_movie_copy_params[:alt_list].present? ? order_movie_copy_params[:alt_list] : 'order_movie_copy'
            render partial: row_partial, locals: { "#{row_partial}": @order_movie_copy }, status: 200
          else

            redirect_to edit_admin_order_movie_copy_path(@order_movie_copy)

          end
        end
        format.json do
          render json: { 'record_id': @order_movie_copy&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Order Movie Copy'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @order_movie_copy&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@order_movie_copy}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@order_movie_copy}"

    respond_to do |format|
      if @order_movie_copy.update(order_movie_copy_params)
        format.html do
          if request.xhr?
            row_partial = order_movie_copy_params[:alt_list].present? ? order_movie_copy_params[:alt_list] : 'order_movie_copy'
            render partial: row_partial, locals: { "#{row_partial}": @order_movie_copy }, status: 200
          else

            redirect_to edit_admin_order_movie_copy_path(@order_movie_copy),
                        notice: 'Order Movie Copy was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @order_movie_copy&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@order_movie_copy}"
            render action: :edit
          end
        end
        format.json { render json: @order_movie_copy.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@order_movie_copy, admin_order_movie_copies_path)
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

  def order_movie_copy_params
    full_attributes = %i[
      movie_copy_id
      order_id
      returned_on
      alt_list
    ]

    params.require(:order_movie_copy)
          .permit(*strong_accessible_params(@order_movie_copy,
                                            OrderMovieCopy,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
