require 'spec_helper'

describe GroupMembersController do
  describe 'GET #new' do
    it 'makes a new record' do
      get :new

      expect(assigns(:group_member)).to be_new_record
    end

    it 'renders the new template' do
      get :new

      expect(response).to render_template('new')
    end
  end
end
