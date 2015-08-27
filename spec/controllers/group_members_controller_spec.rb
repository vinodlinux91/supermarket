require 'spec_helper'

describe GroupMembersController do
  describe 'GET #new' do
    let(:group) { create(:group) }

    it 'finds the correct group' do
      get :new, group: group

      expect(assigns(:group)).to eq(group)
    end

    it 'makes a new record' do
      get :new, group: group

      expect(assigns(:group_member)).to be_new_record
    end

    it 'includes the group as an attribute of the new record' do
      get :new, group: group
      expect(assigns(:group_member).group).to eq(group)
    end

    it 'renders the new template' do
      get :new, group: group

      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    context 'with valid input' do
      let(:input) do
        { group_id: group.id, user_id: user.id }
      end

      it 'saves the new group member to the database' do
        expect { post :create, group_member: input }.to change(GroupMember, :count).by(1)
      end

      context 'after the save' do
        let(:group_member) do
          GroupMember.create(user: user, group: group)
        end

        before do
          allow(GroupMember).to receive(:new).and_return(group_member)
          allow(group_member).to receive(:save).and_return(true)
        end

        it 'shows a success message' do
          post :create, group_member: input
          expect(flash[:notice]).to include('Member successfully added!')
        end

        it 'redirects to the group show template' do
          post :create, group_member: input
          expect(response).to redirect_to(group_path(group))
        end
      end
    end

    context 'with invalid input' do
      let(:invalid_input) do
        { group_id: group.id, user_id: nil }
      end

      it 'does not save the group to the database' do
        expect { post :create, group_member: invalid_input }.to change(GroupMember, :count).by(0)
      end

      context 'after the save' do
        let(:group_member) do
          GroupMember.new(user: user, group: group)
        end

        before do
          allow(GroupMember).to receive(:new).and_return(group_member)
          allow(group_member).to receive(:save).and_return(false)
        end

        it 'shows an error' do
          post :create, group_member: invalid_input
          expect(flash[:warning]).to include('An error has occurred')
        end

        it 'redirects to the new member template' do
          post :create, group_member: invalid_input
          expect(response).to redirect_to(new_group_member_path)
        end
      end
    end
  end
end
