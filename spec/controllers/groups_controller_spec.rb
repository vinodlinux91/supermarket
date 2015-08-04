require 'spec_helper'

describe GroupsController do
  describe 'GET #index' do
    let!(:group_1) { create(:group) }
    let!(:group_2) { create(:group) }

    before do
      get :index
    end

    # Eventually this will only be groups a user is a member of
    it 'finds all (for now) groups' do
      expect(assigns(:groups)).to include(group_1, group_2)
    end

    it 'renders the index template' do
      expect(response).to render_template('index')
    end
  end
end
