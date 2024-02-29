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
    @movie_notification = create(:movie_notification)
  end

  it 'returns http success' do
    get :show, params: { id: @movie_notification.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a movie_notification' do
    expect do
      create(:movie_notification)
    end.to change(MovieNotification, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:movie_notification) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    movie_notification = create(:movie_notification)
    put :update, params: { id: movie_notification.to_param, movie_notification: attributes_for(:movie_notification) }
    expect(response).to redirect_to movie_notification_path(movie_notification)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    movie_notification = create(:movie_notification)
    expect do
      post :destroy, params: { id: movie_notification }
    end.to change(MovieNotification, :count).by(-1)
  end
end
