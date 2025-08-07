class GoalsController < ApplicationController
  before_action :set_goal, only: %i[ show edit update destroy update_progress ]

  # GET /goals
  def index
    @goals = Current.user.goals.includes(:category).ordered

    @goals = filter_goals(@goals) if filtering_params.values.any?(&:present?)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /goals/1
  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /goals/new
  def new
    @goal = Current.user.goals.build
    @categories = Current.user.categories.order(:name)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /goals/1/edit
  def edit
    @categories = Current.user.categories.order(:name)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # POST /goals
  def create
    @goal = Current.user.goals.build(goal_params)
    @categories = Current.user.categories.order(:name)

    if @goal.save
      respond_to do |format|
        format.turbo_stream {
          flash.now[:notice] = "Goal created successfully"
        }
        format.html {
          redirect_to goals_path, notice: "Goal created successfully"
        }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render :new, status: :unprocessable_entity
        }
        format.html {
          render :new, status: :unprocessable_entity
        }
      end
    end
  end

  # PATCH/PUT /goals/1
  def update
    @categories = Current.user.categories.order(:name)

    if @goal.update(goal_params)
      respond_to do |format|
        format.turbo_stream {
          flash.now[:notice] = "Goal updated successfully"
        }
        format.html {
          redirect_to goal_path(@goal), notice: "Goal updated successfully"
        }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render :edit, status: :unprocessable_entity
        }
        format.html {
          render :edit, status: :unprocessable_entity
        }
      end
    end
  end

  # DELETE /goals/1
  def destroy
    @goal.destroy!

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = "Goal deleted successfully"
      }
      format.html {
        redirect_to goals_path, notice: "Goal deleted successfully"
      }
    end
  end

  # PATCH /goals/1/update_progress
  def update_progress
    amount = params[:amount].to_f

    if @goal.update_progress(amount)
      respond_to do |format|
        format.turbo_stream {
          flash.now[:notice] = "Goal progress updated successfully"
        }
        format.html {
          redirect_to goal_path(@goal), notice: "Goal progress updated successfully"
        }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          flash.now[:alert] = "Unable to update goal progress"
          render :show, status: :unprocessable_entity
        }
        format.html {
          redirect_to goal_path(@goal), alert: "Unable to update goal progress"
        }
      end
    end
  end

  private

  def set_goal
    @goal = Current.user.goals.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(:title, :description, :target_amount, :current_amount,
                                 :target_date, :goal_type, :status, :category_id)
  end

  def filtering_params
    params.permit(:status, :goal_type, :search)
  end

  def filter_goals(goals)
    goals = goals.by_status(params[:status]) if params[:status].present?
    goals = goals.by_type(params[:goal_type]) if params[:goal_type].present?
    goals = goals.where("title ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    goals
  end
end
