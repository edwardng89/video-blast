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
    @movie_actor = create(:movie_actor)
  end

  it 'returns http success' do
    get :show, params: { id: @movie_actor.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a movie_actor' do
    expect do
      create(:movie_actor)
    end.to change(MovieActor, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:movie_actor) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    movie_actor = create(:movie_actor)
    put :update, params: { id: movie_actor.to_param, movie_actor: attributes_for(:movie_actor) }
    expect(response).to redirect_to movie_actor_path(movie_actor)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    movie_actor = create(:movie_actor)
    expect do
      post :destroy, params: { id: movie_actor }
    end.to change(MovieActor, :count).by(-1)
  end
end
