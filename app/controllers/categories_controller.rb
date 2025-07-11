class CategoriesController < ApplicationController
  include ActionView::RecordIdentifier
  
  before_action :set_category, only: %i[ show edit update destroy ]
  
  def index
    @categories = Current.user.categories.ordered
  end
  
  def show
    @recent_transactions = @category.transactions.recent
  end
  
  def new
    @category = Current.user.categories.build
  end
  
  def edit
  end
  
  def create
    @category = Current.user.categories.build(category_params)
    
    if @category.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to categories_path, notice: "Category was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @category.update(category_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to categories_path, notice: "Category was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @category.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to categories_path, notice: "Category was successfully deleted." }
      end
    else
      redirect_to categories_path, alert: @category.errors.full_messages.join(", ")
    end
  end
  
  private
    def set_category
      @category = Current.user.categories.find(params[:id])
    end
    
    def category_params
      params.require(:category).permit(:name, :color)
    end
end