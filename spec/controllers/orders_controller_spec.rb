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
    @order = create(:order)
  end

  it 'returns http success' do
    get :show, params: { id: @order.id }
    expect(response).to be_successful
  end
end

describe 'POST create' do
  before do
    sign_in create(:user)
  end

  it 'creates a order' do
    expect do
      create(:order)
    end.to change(Order, :count).by(1)
  end
end

describe 'GET edit' do
  before do
    sign_in create(:user)
  end

  it 'returns successfully' do
    get :edit, params: { id: create(:order) }
    expect(response).to be_successful
  end
end

describe 'POST update' do
  before do
    sign_in create(:user)
  end

  it 'updates the record' do
    order = create(:order)
    put :update, params: { id: order.to_param, order: attributes_for(:order) }
    expect(response).to redirect_to order_path(order)
  end
end

describe 'POST destroy' do
  before do
    sign_in create(:user)
  end

  it 'deletes the record' do
    order = create(:order)
    expect do
      post :destroy, params: { id: order }
    end.to change(Order, :count).by(-1)
  end
end
