require 'rails_helper'

RSpec.describe "Brands", type: :request do
  let(:brand) { create(:brand) }

  describe "GET /brands" do
    it "returns http success" do
      get brands_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /brands/:id" do
    it "returns http success" do
      get brand_path(brand)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /brands/new" do
    context "when not logged in" do
      it "redirects to login" do
        get new_brand_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "returns http success" do
        get new_brand_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /brands" do
    context "when logged in as admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "creates a new brand" do
        expect {
          post brands_path, params: { brand: { name: 'New Brand' } }
        }.to change(Brand, :count).by(1)
      end
    end
  end
end
