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
    @genre = create(:genre)
  end

  it 'returns http success' do
    get :show, params: { id: @genre.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a genre' do
    expect do
      create(:genre)
    end.to change(Genre, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:genre) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    genre = create(:genre)
    put :update, params: { id: genre.to_param, genre: attributes_for(:genre) }
    expect(response).to redirect_to genre_path(genre)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    genre = create(:genre)
    expect do
      post :destroy, params: { id: genre }
    end.to change(Genre, :count).by(-1)
  end
end
