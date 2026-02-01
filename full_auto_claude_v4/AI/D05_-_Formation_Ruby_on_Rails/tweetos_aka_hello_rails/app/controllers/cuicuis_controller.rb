# frozen_string_literal: true

# CuicuisController handles CRUD operations for cuicuis (tweets)
class CuicuisController < ApplicationController
  before_action :set_cuicui, only: %i[show edit update destroy]

  def index
    @cuicuis = Cuicui.all
  end

  def show; end

  def new
    @cuicui = Cuicui.new
  end

  def edit; end

  def create
    @cuicui = Cuicui.new(cuicui_params)
    if @cuicui.save
      redirect_to @cuicui, notice: 'Cuicui was successfully created.'
    else
      render :new
    end
  end

  def update
    if @cuicui.update(cuicui_params)
      redirect_to @cuicui, notice: 'Cuicui was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @cuicui.destroy
    redirect_to cuicuis_url, notice: 'Cuicui was successfully destroyed.'
  end

  def top
    @cuicuis = Cuicui.top
  end

  private

  def set_cuicui
    @cuicui = Cuicui.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cuicuis_path, alert: 'Cuicui not found'
  end

  def cuicui_params
    params.require(:cuicui).permit(:content, :user_id)
  end
end
