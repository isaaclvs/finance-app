class TransactionsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_transaction, only: %i[ show edit update destroy ]
  before_action :load_categories, only: %i[ new edit create update ]

  def index
    @recent_transactions = Current.user.transactions.includes(:category).ordered.limit(10)
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
        format.turbo_stream
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
        format.turbo_stream
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
          turbo_stream.remove("#{dom_id(@transaction)}_mobile"),
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
