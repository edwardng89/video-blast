render_views

describe 'GET #index' do
  before do
    sign_in create(:user)
  end

  it 'returns http success' do
    get :index
    expect(response).to be_successful
  end
end

describe 'GET #show' do
  before do
    sign_in create(:user)
    @communication_record = create(:communication_record)
  end

  it 'returns http success' do
    get :show, params: { id: @communication_record.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a communication_record' do
    expect do
      create(:communication_record)
    end.to change(CommunicationRecord, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:communication_record) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    communication_record = create(:communication_record)
    put :update,
        params: { id: communication_record.to_param, communication_record: attributes_for(:communication_record) }
    expect(response).to redirect_to communication_record_path(communication_record)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    communication_record = create(:communication_record)
    expect do
      post :destroy, params: { id: communication_record }
    end.to change(CommunicationRecord, :count).by(-1)
  end
end
