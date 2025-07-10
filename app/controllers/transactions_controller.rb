class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]
  before_action :load_categories, only: %i[ new edit create update ]
  
  def index
    @transactions = Current.user.transactions.includes(:category)
    
    @transactions = @transactions.by_type(params[:transaction_type]) if params[:transaction_type].present?
    @transactions = @transactions.by_category(params[:category_id]) if params[:category_id].present?
    @transactions = @transactions.search_description(params[:search]) if params[:search].present?
    
    if params[:period].present?
      case params[:period]
      when "today"
        @transactions = @transactions.where(date: Date.current)
      when "week"
        @transactions = @transactions.where(date: Date.current.beginning_of_week..Date.current.end_of_week)
      when "month"
        @transactions = @transactions.by_month(Date.current)
      when "custom"
        if params[:start_date].present? && params[:end_date].present?
          @transactions = @transactions.by_date_range(params[:start_date], params[:end_date])
        end
      end
    end
    
    @transactions = @transactions.ordered.page(params[:page]).per(20)
    
    @categories = Current.user.categories.ordered
    
    @totals = Current.user.balance_data
  end
  
  def show
  end
  
  def new
    @transaction = Current.user.transactions.build
    @transaction.date = Date.current
  end
  
  def edit
  end
  
  def create
    @transaction = Current.user.transactions.build(transaction_params)
    
    if @transaction.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("transactions_list", partial: "transactions/transaction", locals: { transaction: @transaction }),
            turbo_stream.update("balance_summary", partial: "shared/balance_summary", locals: { user: Current.user })
          ]
        end
        format.html { redirect_to transactions_path, notice: "Transaction was successfully created." }
      end
    else
      load_categories
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @transaction.update(transaction_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(dom_id(@transaction), partial: "transactions/transaction", locals: { transaction: @transaction }),
            turbo_stream.update("balance_summary", partial: "shared/balance_summary", locals: { user: Current.user })
          ]
        end
        format.html { redirect_to transactions_path, notice: "Transaction was successfully updated." }
      end
    else
      load_categories
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @transaction.destroy
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@transaction)),
          turbo_stream.update("balance_summary", partial: "shared/balance_summary", locals: { user: Current.user })
        ]
      end
      format.html { redirect_to transactions_path, notice: "Transaction was successfully deleted." }
    end
  end
  
  private
    def set_transaction
      @transaction = Current.user.transactions.find(params[:id])
    end
    
    def transaction_params
      params.require(:transaction).permit(:amount, :transaction_type, :date, :description, :category_id)
    end
    
    def load_categories
      @categories = Current.user.categories.ordered
    end
end
