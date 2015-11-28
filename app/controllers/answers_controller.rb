class AnswersController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :load_question
  before_action :load_answer, only: [:show, :update, :destroy]
  before_action :check_current_user, only: [:update, :destroy]

  def show
  end

  def create
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user
    if @answer.save
      flash.now[:success] = "Ответ был создан!"
    end
  end

  def update
    if @answer.update_attributes(answer_params)
      flash.now[:success] = "Ответ был изменен!"
    end
  end

  def destroy
    @answer.destroy
    flash.now[:success] = "Ответ был удален!"
  end

  private
    def load_question
      @question = Question.find(params[:question_id])
    end

    def load_answer
      @answer = @question.answers.find(params[:id])
    end

    def answer_params
      params.require(:answer).permit(:body)
    end  

    def check_current_user
      redirect_to root_url unless @answer.user == current_user
    end
end
