class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]

  def index
    @books = Book.all
    @book = Book.new
  end

  def show
  end

  def new
    @book = Book.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @book = Book.new(book_params)
    respond_to do |format|
      if @book.save
        @books = Book.all
        format.html { redirect_to books_path, notice: "Book was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.js { render :create_error }
      end
    end
  end

  def update
    respond_to do |format|
      if @book.update(book_params)
        @books = Book.all
        format.html { redirect_to @book, notice: "Book was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js { render :update_error }
      end
    end
  end

  def destroy
    @book.destroy
    @books = Book.all
    respond_to do |format|
      format.html { redirect_to books_path, status: :see_other, notice: "Book was successfully destroyed." }
      format.js
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:name)
  end
end
