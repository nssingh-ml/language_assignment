class PostRevisionsController < ApplicationController
    def index
        @post = Post.find(params[:post_id])
        @revisions = @post.post_revisions
        render json: @revisions
      end
    
      def show
        @revision = @post.post_revisions.find(params[:id])
        render json: @revision
      end
    
      private
    
      def set_post
        @post = Post.find(params[:post_id])
      end

end
