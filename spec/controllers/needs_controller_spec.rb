# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NeedsController, type: :controller do
  let(:user) { need.user }
  let(:need) { create(:need_with_shifts) }
  let(:another_need) do
    create(:need_with_shifts, start_at: 1.day.from_now, user: user, office: need.office)
  end

  before { sign_in user }

  describe '#index' do
    it 'GET index' do
      another_need

      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:needs).to_a).to eql([need, another_need])
    end
  end

  describe '#show' do
    it 'returns ok and sets expected variables' do
      get :show, params: { id: need.id }
      expect(response).to have_http_status(:ok)
      expect(flash[:alert]).to be nil
    end
  end

  describe '#create' do
    it 'POST create' do
      expect do
        post :create, params: { need: { number_of_children: 2,
                                        expected_duration:  2,
                                        start_at:           Time.zone.now.advance(weeks: 1).to_param,
                                        office_id:          need.office_id.to_param,
                                        age_range_ids:      [AgeRange.first!.id],
                                        preferred_language_id: 1 } }
      end.to change(Need, :count).by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe '#edit' do
    it 'GET edit' do
      get :edit, params: { id: need.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe '#update' do
    it 'PATCH update' do
      patch :update, params: { id: need.id, need: { number_of_children: 2 } }

      expect(response).to have_http_status(:found)
      expect(need.reload.number_of_children).to equal(2)
    end
  end

  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, params: { id: need.id }

      expect(response).to have_http_status(:found)
      expect { need.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#mark_unavailable' do
    subject { patch :mark_unavailable, params: { id: need.id } }
    it { is_expected.to redirect_to(need) }
  end
end
