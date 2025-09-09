module Api
  module V1
    class ChallengesController < ApplicationController
      before_action :set_challenge, only: [:update, :destroy]
      before_action :authenticate_user!, only: [:create ,:update, :destroy]
      before_action :authorize_admin, only: [:create, :update, :destroy]

      # GET /api/v1/challenges
      def index
        @challenges = Challenge.all
        render json: {"Challenges": @challenges}
      end

      # GET /api/v1/challenges/:id
      def show
        challenge = Challenge.find_by(id: params[:id].to_i)
        if challenge.nil?
          render json: { error: 'Challenge not found' }, status: :not_found
          return
        end
        render json: challenge
      end

      # POST /api/v1/challenges
      def create
        @challenge = current_user.challenges.new(challenge_params)
        if @challenge.save
          render json: @challenge, status: :created
        else
          render json: @challenge.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/challenges/:id
      def update
        if @challenge.update(challenge_params)
          render json: @challenge
        else
          render json: @challenge.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/challenges/:id
      def destroy
        @challenge.destroy
        head :no_content
      end

      private

      def authorize_admin
        unless current_user.email == ENV['ADMIN_EMAIL']
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def set_challenge
        @challenge = current_user.challenges.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Challenge not found' }, status: :not_found
      end

      def challenge_params
        params.require(:challenge).permit(:title, :description, :start_date, :end_date)
      end
    end
  end
end