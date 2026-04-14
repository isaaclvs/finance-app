class TagsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_tag, only: %i[edit update destroy]

  def index
    @tags = Current.user.tags.ordered
  end

  def new
    @tag = Current.user.tags.build(color: "#6366F1")
  end

  def edit
  end

  def create
    @tag = Current.user.tags.build(tag_params)

    if @tag.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tags_path, notice: t("notices.tags.created") }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tags_path, notice: t("notices.tags.updated") }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tags_path, notice: t("notices.tags.deleted") }
    end
  end

  private

  def set_tag
    @tag = Current.user.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end