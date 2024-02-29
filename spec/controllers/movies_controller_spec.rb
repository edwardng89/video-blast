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
    @movie = create(:movie)
  end

  it 'returns http success' do
    get :show, params: { id: @movie.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a movie' do
    expect do
      create(:movie)
    end.to change(Movie, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:movie) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    movie = create(:movie)
    put :update, params: { id: movie.to_param, movie: attributes_for(:movie) }
    expect(response).to redirect_to movie_path(movie)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    movie = create(:movie)
    expect do
      post :destroy, params: { id: movie }
    end.to change(Movie, :count).by(-1)
  end
end
