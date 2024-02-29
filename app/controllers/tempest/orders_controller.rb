class Tempest::OrdersController < AdminController
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource :user
  load_and_authorize_resource through: [:user], shallow: true

  respond_to :html
  has_scope :query

  decorates_assigned :orders, :order

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Rentals'

    @orders = apply_scopes(@orders.includes(:user))
    respond_with(@orders) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @orders = @orders.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@user, :orders])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @orders = Order.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @orders = @orders
                  .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @orders.compact
      end
      format.js do
        @orders = @orders.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@user, :orders])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @orders
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @order

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Rental'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@order}"

    respond_to do |format|
      if @order.save
        format.html do
          if request.xhr?
            row_partial = order_params[:alt_list].present? ? order_params[:alt_list] : 'order'
            render partial: row_partial, locals: { "#{row_partial}": @order }, status: 200
          else

            redirect_to edit_admin_order_path(@order)

          end
        end
        format.json do
          render json: { 'record_id': @order&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Order'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @order&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@order}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@order}"

    respond_to do |format|
      if @order.update(order_params)
        format.html do
          if request.xhr?
            row_partial = order_params[:alt_list].present? ? order_params[:alt_list] : 'order'
            render partial: row_partial, locals: { "#{row_partial}": @order }, status: 200
          else

            redirect_to edit_admin_order_path(@order), notice: 'Order was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @order&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@order}"
            render action: :edit
          end
        end
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@order, admin_orders_path)
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
    return unless @user

    @allow_create = true
    @full_edit_create = false
    @default_limit = 25
    @allow_filter = true
    @pdf_button = false
    @copy_button = false
    @csv_button = false
    @xls_button = false
    @print_button = false
    @icon = ''

    ## nested model setup ends ##
  end

  def order_params
    full_attributes = [
      { order_movie_copy_ids: [] },
      :return_due,
      :status,
      :user_id,
      :alt_list
    ]

    params.require(:order)
          .permit(*strong_accessible_params(@order,
                                            Order,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
