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
    @user_rating = create(:user_rating)
  end

  it 'returns http success' do
    get :show, params: { id: @user_rating.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a user_rating' do
    expect do
      create(:user_rating)
    end.to change(UserRating, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:user_rating) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    user_rating = create(:user_rating)
    put :update, params: { id: user_rating.to_param, user_rating: attributes_for(:user_rating) }
    expect(response).to redirect_to user_rating_path(user_rating)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    user_rating = create(:user_rating)
    expect do
      post :destroy, params: { id: user_rating }
    end.to change(UserRating, :count).by(-1)
  end
end
