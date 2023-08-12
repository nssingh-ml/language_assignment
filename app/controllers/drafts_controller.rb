class DraftsController < ApplicationController

    before_action :authenticate_request
    before_action :set_draft, only: [:show, :update, :publish]

    def index
        drafts = Draft.all
        render json: drafts
      end

    def create
        draft = current_user.drafts.build(draft_params)
        if draft.save
        render json: draft, status: :created
        else
        render json: { errors: draft.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        if @draft.update(draft_params)
        render json: @draft
        else
        render json: { errors: @draft.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def show_all
        drafts = current_user.drafts
        render json: drafts
    end

    def publish
        # Logic to publish the draft, e.g., create a new Post
        post = Post.create(title: @draft.title, topic: @draft.topic, description: @draft.description, image: @draft.image, user: @draft.user)
        @draft.destroy
        render json: { message: 'Draft published successfully' }
    end

    private

    def set_draft
        @draft = Draft.find(params[:id])
    end

    def draft_params
        params.permit(:title, :topic_id, :description, :image)
    end

end
