class BrandsController < ApplicationController
  before_action :set_brand, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @brands = Brand.page(params[:page]).per(25)
  end

  def show
    @products = @brand.products.page(params[:page]).per(25)
  end

  def new
    @brand = Brand.new
  end

  def edit
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      redirect_to @brand, notice: 'Brand was successfully created.'
    else
      render :new
    end
  end

  def update
    if @brand.update(brand_params)
      redirect_to @brand, notice: 'Brand was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @brand.destroy
    redirect_to brands_url, notice: 'Brand was successfully deleted.'
  end

  private

  def set_brand
    @brand = Brand.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to brands_url, alert: 'Brand not found.'
  end

  def brand_params
    params.require(:brand).permit(:name, :avatar)
  end
end
