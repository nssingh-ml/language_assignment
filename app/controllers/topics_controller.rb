class TopicsController < ApplicationController
    skip_before_action :authenticate_request
    before_action :set_topic, only: [:show, :edit, :update, :destroy]

  def index
    @topics = Topic.all
    render json: @topics
  end

  def show
    render json: @topic
  end

  def new
    @topic = Topic.new
  end

  def create
    topic = Topic.new(topic_params)
    if topic.save
    #   redirect_to @topic, notice: 'Topic was successfully created.'
      render json:topic, status: :created
    else
      render :new, notice: 'Topic was unsuccessfully created.'
    end
  end

  def edit
  end

  def update
    if @topic.update(topic_params)
      render json: @topic, notice: 'Topic was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @topic.destroy
    redirect_to topics_url, notice: 'Topic was successfully deleted.'
  end

  private

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def topic_params
    # params.require(:topic).permit(:name)
    params.permit(:name)
  end
end
