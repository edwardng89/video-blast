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
    @movie_genre = create(:movie_genre)
  end

  it 'returns http success' do
    get :show, params: { id: @movie_genre.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a movie_genre' do
    expect do
      create(:movie_genre)
    end.to change(MovieGenre, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:movie_genre) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    movie_genre = create(:movie_genre)
    put :update, params: { id: movie_genre.to_param, movie_genre: attributes_for(:movie_genre) }
    expect(response).to redirect_to movie_genre_path(movie_genre)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    movie_genre = create(:movie_genre)
    expect do
      post :destroy, params: { id: movie_genre }
    end.to change(MovieGenre, :count).by(-1)
  end
end
