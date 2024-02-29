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
    @actor = create(:actor)
  end

  it 'returns http success' do
    get :show, params: { id: @actor.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a actor' do
    expect do
      create(:actor)
    end.to change(Actor, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:actor) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    actor = create(:actor)
    put :update, params: { id: actor.to_param, actor: attributes_for(:actor) }
    expect(response).to redirect_to actor_path(actor)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    actor = create(:actor)
    expect do
      post :destroy, params: { id: actor }
    end.to change(Actor, :count).by(-1)
  end
end
