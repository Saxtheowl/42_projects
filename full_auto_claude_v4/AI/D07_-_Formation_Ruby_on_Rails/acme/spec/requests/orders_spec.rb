require 'rails_helper'

RSpec.describe "Orders", type: :request do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }

  describe "GET /orders" do
    context "when not logged in" do
      it "redirects to login" do
        get orders_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { sign_in user }

      it "returns http success" do
        get orders_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /orders/:id" do
    context "when not logged in" do
      it "redirects to login" do
        get order_path(order)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as order owner" do
      before { sign_in user }

      it "returns http success" do
        get order_path(order)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
