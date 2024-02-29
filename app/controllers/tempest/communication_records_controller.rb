class Tempest::CommunicationRecordsController < AdminController
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource
  respond_to :html
  has_scope :query

  decorates_assigned :communication_records, :communication_record

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Communication Records'

    @communication_records = apply_scopes(@communication_records)
    respond_with(@communication_records) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @communication_records = @communication_records.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:communication_records])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @communication_records = CommunicationRecord.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @communication_records = @communication_records
                                 .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @communication_records.compact
      end
      format.js do
        @communication_records = @communication_records.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:communication_records])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @communication_records
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @communication_record

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Communication Record'
  end

  def create
    @title = "Edit #{@communication_record}"

    respond_to do |format|
      if @communication_record.save
        format.html do
          redirect_to edit_admin_communication_record_path(@communication_record)
        end

        format.json do
          render json: { 'record_id': @communication_record&.id }
        end

      else
        format.html do
          @title = 'New Communication Record'
          render action: :new
        end
      end
    end
  end

  def edit
    @title = "Edit #{@communication_record}"
    render partial: 'form' if request.xhr? && params[:single_show_edit]
  end

  def update
    @title = "Edit #{@communication_record}"

    respond_to do |format|
      if @communication_record.update(communication_record_params)
        format.html do
          redirect_to edit_admin_communication_record_path(@communication_record),
                      notice: 'Communication Record was successfully updated.'
        end
      else
        format.html do
          @title = "Edit #{@communication_record}"
          render action: :edit
        end
      end
    end
  end

  def destroy
    destroy_common(@communication_record, admin_communication_records_path)
  end

  # -- custom_actions_starts --
  # -- custom_actions_ends --

  private

  def index_setup
    @allow_create = false
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

  def communication_record_params
    full_attributes = %i[
      body
      communication_recordable_id
      communication_recordable_type
      from
      received_at
      sent_at
      subject
      to
      alt_list
    ]

    params.require(:communication_record)
          .permit(*strong_accessible_params(@communication_record,
                                            CommunicationRecord,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
