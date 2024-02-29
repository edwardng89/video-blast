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
    @user = create(:user)
  end

  it 'returns http success' do
    get :show, params: { id: @user.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a user' do
    expect do
      create(:user)
    end.to change(User, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:user) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    user = create(:user)
    put :update, params: { id: user.to_param, user: attributes_for(:user) }
    expect(response).to redirect_to user_path(user)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    user = create(:user)
    expect do
      post :destroy, params: { id: user }
    end.to change(User, :count).by(-1)
  end
end
