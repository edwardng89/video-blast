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
    @movie_copy = create(:movie_copy)
  end

  it 'returns http success' do
    get :show, params: { id: @movie_copy.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a movie_copy' do
    expect do
      create(:movie_copy)
    end.to change(MovieCopy, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:movie_copy) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    movie_copy = create(:movie_copy)
    put :update, params: { id: movie_copy.to_param, movie_copy: attributes_for(:movie_copy) }
    expect(response).to redirect_to movie_copy_path(movie_copy)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    movie_copy = create(:movie_copy)
    expect do
      post :destroy, params: { id: movie_copy }
    end.to change(MovieCopy, :count).by(-1)
  end
end
