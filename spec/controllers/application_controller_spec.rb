# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  # No render_views here because we don't have views defined for dummy controller

  controller do
    skip_authorization_check
    # Defining a dummy action for an anonymous controller which inherits from the described class.
    def index
      puts controller_name
    end
  end

  before do
    # @controller = ApplicationController.new
    # To handle different naming of sub domain column
    sub_domain_column = (.column_names & %w[subdomain sub_domain])&.first
    @ = create(:, "#{sub_domain_column}": 'adelaide')
    # FIXME: relies on Devise model belonging to the tenancy object
    sign_in create(:user, role: 'super_user', : @)
  end

  context 'when accessed via valid sub domain' do
    it 'sets the subdomain_ along with the session' do
      @request.host = 'adelaide.example.com.au'

      get :index
      expect(assigns(:subdomain_)).to eq(@)
      expect(session[:current__id]).to eq(@.id)
    end
  end

  context 'when accessed via invalid sub domain' do
    it 'does not set the subdomain_ or the session' do
      @request.host = 'foo.example.com.au'

      get :index
      expect(assigns(:subdomain_)).to be_nil
      expect(session[:current__id]).to be_nil
    end
  end

  context 'when accessed via no sub domain' do
    it 'does not set the subdomain_ or the session' do
      @request.host = 'example.com.au'

      get :index
      expect(assigns(:subdomain_)).to be_nil
      expect(session[:current__id]).to be_nil
    end
  end
end
