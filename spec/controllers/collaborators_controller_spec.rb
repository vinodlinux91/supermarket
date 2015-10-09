require 'spec_helper'

describe CollaboratorsController do
  let!(:fanny) { create(:user, first_name: 'Fanny') }
  let!(:hank) { create(:user, first_name: 'Hank') }
  let!(:hanky) { create(:user, first_name: 'Hanky') }
  let!(:cookbook) { create(:cookbook, owner: fanny) }
  let!(:existing_collaborator) { create(:user, collaborated_cookbooks: [cookbook]) }

  describe 'GET #index' do
    before do
      sign_in fanny
    end

    it 'returns only collaborators matching the query string' do
      get :index, cookbook_id: cookbook, q: 'hank', format: :json
      collaborators = assigns[:collaborators]
      expect(collaborators.count(:all)).to eql(2)
      expect(collaborators.first).to eql(hank)
      expect(response).to be_success
    end

    it "doesn't return users that are ineligible" do
      get :index, cookbook_id: cookbook, format: :json, ineligible_user_ids: [fanny.id, existing_collaborator.id]
      collaborators = assigns[:collaborators]
      expect(collaborators.size).to eql(2)
      expect(collaborators).to include(hank)
      expect(collaborators).to include(hanky)
      expect(collaborators).to_not include(fanny)
      expect(collaborators).to_not include(existing_collaborator)
      expect(response).to be_success
    end
  end

  describe 'destructive updates' do
    describe 'POST #create' do
      it 'creates a collaborator if the signed in user is the resource owner' do
        sign_in fanny

        expect do
          post :create, collaborator: { user_ids: hank.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end.to change { Collaborator.count }.by(1)
        expect(response).to redirect_to(cookbook)
      end

      it 'sends the collaborator an email' do
        sign_in fanny

        Sidekiq::Testing.inline! do
          expect do
            post :create, collaborator: { user_ids: hank.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
          end.to change { ActionMailer::Base.deliveries.size }.by(1)
        end
      end

      it 'fails if the signed in user is not the resource owner' do
        sign_in hanky

        expect do
          post :create, collaborator: { user_ids: hank.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end.to_not change { Collaborator.count }

        expect(response.status).to eql(404)
      end

      it 'does not include the resource owner if the resource owner tries to add themselves as a contributor' do
        sign_in fanny

        expect do
          post :create, collaborator: { user_ids: fanny.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end.to change { Collaborator.count }.by(0)
      end

      it 'returns a 404 if an unknown resource type is in the params' do
        sign_in fanny

        post :create, collaborator: { user_ids: hank.id, resourceable_type: 'Butter', resourceable_id: cookbook.id }

        expect(response.status).to eql(404)
      end

      context 'adding a collaborator group' do
        let(:group_member) { create(:group_member) }
        let(:group) { group_member.group }
        let(:new_collaborator) { build(:cookbook_collaborator, resourceable: cookbook) }

        before do
          expect(cookbook.owner).to eq(fanny)
          sign_in fanny
        end

        it 'finds the correct group' do
          expect(Group).to receive(:find).with(group.id.to_s).and_return(group)
          post :create, collaborator: { group_ids: group.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end

        it 'finds the users for the group' do
          allow(Group).to receive(:find).and_return(group)
          expect(group).to receive(:members).and_return(group.group_members)
          post :create, collaborator: { group_ids: group.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end

        it 'makes new collaborators for the group members' do
          expect(Collaborator).to receive(:new).with( user_id: group_member.user.id, resourceable: cookbook ).and_return(new_collaborator)
          post :create, collaborator: { group_ids: group.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end

        it 'saves each collaborator' do
          allow(Collaborator).to receive(:new).and_return(new_collaborator)
          expect(new_collaborator).to receive(:save!)
          post :create, collaborator: { group_ids: group.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end

        it 'queues a collaborator mailer for each collaborator' do
          allow(Collaborator).to receive(:new).and_return(new_collaborator)

          collaborator_mailer = double('CollaboratorMailer', delay: 'true')
          expect(CollaboratorMailer).to receive(:delay).and_return(collaborator_mailer)

          expect(collaborator_mailer).to receive(:added_email).with(new_collaborator)
          post :create, collaborator: { group_ids: group.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
        end

        context 'when adding a collaborator group to a tool' do
          let(:tool) { create(:tool, owner: fanny) }

          before do
            expect(cookbook.owner).to eq(fanny)
            sign_in fanny
          end

          it 'makes new collaborators for the group members' do
            expect(Collaborator).to receive(:new).with( user_id: group_member.user.id, resourceable: tool ).and_return(new_collaborator)
            post :create, collaborator: { group_ids: group.id, resourceable_type: 'Tool', resourceable_id: tool.id }
          end
        end

        context 'adding multiple collaborator groups' do
          let(:group_member2) { create(:group_member) }
          let(:group2) { group_member.group }
          let(:new_collaborator2) { build(:cookbook_collaborator, resourceable: cookbook) }

          before do
            expect(cookbook.owner).to eq(fanny)
            sign_in fanny
          end

          it 'finds all groups' do
            expect(Group).to receive(:find).twice.and_return(group, group2)
            post :create, collaborator: { group_ids: group.id, resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
          end

          it 'makes new collaborators for all group members' do
            expect(Collaborator).to receive(:new)#.with( { user_id: group_member.user.id, resourceable: cookbook }, { user_id: group_member2.user_id, resourceable: cookbook }).and_return(new_collaborator)
            post :create, collaborator: { group_ids: [ group.id, group2.id], resourceable_type: 'Cookbook', resourceable_id: cookbook.id }
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: hank) }

      it 'calls the remove collaborator method' do
        sign_in fanny
        expect(controller).to receive(:remove_collaborator).with(collaborator)
        delete :destroy, id: collaborator, format: :js
      end
    end

    describe 'PUT #transfer' do
      let!(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: hank) }

      it 'transfers ownership to a collaborator if the signed in user is the resource owner' do
        sign_in fanny

        put :transfer, id: collaborator
        expect(cookbook.reload.owner).to eql(collaborator.user)
        expect(response).to redirect_to(cookbook_path(cookbook))
      end

      it 'fails if the signed in user is not the resource owner' do
        sign_in hank

        put :transfer, id: collaborator
        expect(response.status).to eql(404)
      end
    end
  end
end
