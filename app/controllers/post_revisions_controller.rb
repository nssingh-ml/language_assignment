class PostRevisionsController < ApplicationController
    def index
        @post = Post.find(params[:post_id])
        @revisions = @post.post_revisions
        render json: @revisions
      end
    
      def show
        @post = Post.find(params[:post_id])
        @revision = @post.post_revisions.find(params[:id])
        render json: @revision
      end
      

      def create
        @post = Post.find(params[:post_id])
        # @revision = @post.post_revisions.build(content: @post.description, user: @current_user)
        @revision = @post.post_revisions.build(content: @post.description, post: @post,editor: @current_user)
        
        if @revision.save
          render json: @revision, status: :created
        else
          render json: { errors: @revision.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
    
      def set_post
        @post = Post.find(params[:post_id])
      end

end
