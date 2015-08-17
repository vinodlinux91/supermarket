require 'spec_helper'

describe GroupsController do
  describe 'GET #new' do
    it 'makes a new record' do
      get :new

      expect(assigns(:group)).to be_new_record
    end

    it 'renders the  new template' do
      get :new

      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    context 'with valid input' do
      let(:group_input) do
        { name: 'My Group' }
      end

      it 'saves the new group to the database' do
        expect{
          post :create, group: group_input
        }.to change(Group, :count).by(1)
      end

      context 'after the save' do
        let(:group) { create(:group) }

        before do
          allow(Group).to receive(:new).and_return(group)
          allow(group).to receive(:save).and_return(true)
        end

        it 'shows a success message' do
          post :create, group: group_input
          expect(flash[:notice]).to include('Group successfully created!')
        end

        it 'rendirects to the group show template' do
          post :create, group: group_input
          expect(response).to redirect_to(group_path(assigns[:group]))
        end
      end

      context 'with invalid input' do
        let(:group_input) do
          { name: '' }
        end

        it 'does not save the group to the database' do
          expect{
            post :create, group: group_input
          }.to change(Group, :count).by(0)
        end

        context "after the save" do
          let(:group) { create(:group) }

          before do
            allow(Group).to receive(:new).and_return(group)
            allow(group).to receive(:save).and_return(false)
          end

          it 'shows an error' do
            post :create, group: group_input
            expect(flash[:warning]).to include('An error has occurred')
          end

          it 'redirects to the new group template' do
            post :create, group: group_input
            expect(response).to redirect_to(new_group_path)
          end
        end
      end
    end
  end

  describe 'GET #show' do
    let(:group) { create(:group) }

    it 'finds the correct group' do
      get :show, id: group
      expect(assigns(:group)).to eq(group)
    end

    it 'renders the group show template' do
      get :show, id: group
      expect(response).to render_template('show')
    end
  end
end
