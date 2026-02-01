require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand) }

  describe "GET /products" do
    it "returns http success" do
      get products_path
      expect(response).to have_http_status(:success)
    end

    it "displays products" do
      product
      get products_path
      expect(response.body).to include(product.name)
    end
  end

  describe "GET /products/:id" do
    it "returns http success" do
      get product_path(product)
      expect(response).to have_http_status(:success)
    end

    it "displays product details" do
      get product_path(product)
      expect(response.body).to include(product.name)
    end
  end

  describe "GET /products/new" do
    context "when not logged in" do
      it "redirects to login" do
        get new_product_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "returns http success" do
        get new_product_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /products" do
    context "when logged in as admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "creates a new product" do
        expect {
          post products_path, params: { product: { name: 'New Product', price: 29.99, brand_id: brand.id } }
        }.to change(Product, :count).by(1)
      end
    end
  end

  describe "DELETE /products/:id" do
    context "when logged in as admin" do
      let(:admin) { create(:user, :admin) }
      let!(:product_to_delete) { create(:product, brand: brand) }

      before { sign_in admin }

      it "deletes the product" do
        expect {
          delete product_path(product_to_delete)
        }.to change(Product, :count).by(-1)
      end
    end
  end
end
