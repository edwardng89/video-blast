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
    @order_movie_copy = create(:order_movie_copy)
  end

  it 'returns http success' do
    get :show, params: { id: @order_movie_copy.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a order_movie_copy' do
    expect do
      create(:order_movie_copy)
    end.to change(OrderMovieCopy, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:order_movie_copy) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    order_movie_copy = create(:order_movie_copy)
    put :update, params: { id: order_movie_copy.to_param, order_movie_copy: attributes_for(:order_movie_copy) }
    expect(response).to redirect_to order_movie_copy_path(order_movie_copy)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    order_movie_copy = create(:order_movie_copy)
    expect do
      post :destroy, params: { id: order_movie_copy }
    end.to change(OrderMovieCopy, :count).by(-1)
  end
end
