class Api::V1::AnswersController < Api::V1::BaseController
  before_action :load_question, except: [:create]
  authorize_resource

  def index
    @answers = @question.answers.all
    respond_with @answers
  end

  def show
    @answer = @question.answers.find(params[:id])
    respond_with @answer, serializer: AnswerShowSerializer
  end

  def create
    @answer = current_resource_owner.answers.create(answer_params.merge({question_id: params[:question_id]}))
    respond_with @answer, serializer: AnswerShowSerializer
  end

  private
    def load_question
      @question = Question.find(params[:question_id])
    end

    def answer_params
      params.require(:answer).permit(:body)
    end
end