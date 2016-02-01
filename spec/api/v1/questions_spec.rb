require 'rails_helper'

RSpec.describe 'Questions API', type: :request do
  describe 'GET /' do
    it_behaves_like 'unauthorized api', '/api/v1/questions'

    context 'authorized' do
      let(:access_token) { create(:doorkeeper_access_token) }
      let!(:questions) { create_list(:question_multi, 2) }
      let(:question) { questions.first }
      let!(:answers) { create_list(:answer_multi, 3, question: question) }
      # Чтобы не было проблем с сортировкой, берем через скоуп
      let(:answer) { question.answers.first }

      before { get '/api/v1/questions', format: :json, access_token: access_token.token }

      it 'returns 200 status code' do
        expect(response).to be_success
      end

      it 'returns list of questions' do
        expect(response.body).to have_json_size(2).at_path("questions")
      end

      %w(id title body created_at updated_at).each do |attr|
        it "question object contains #{attr}" do
          expect(response.body).to be_json_eql(question.send(attr.to_sym).to_json).at_path("questions/0/#{attr}")
        end
      end

      it 'question object contains short_title' do
        expect(response.body).to be_json_eql(question.title.truncate(10).to_json).at_path("questions/0/short_title")
      end

      context 'answers' do
        it 'included in question object' do
          expect(response.body).to have_json_size(3).at_path("questions/0/answers")
        end

        %w(id body created_at updated_at).each do |attr|
          it "contains #{attr}" do
            expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("questions/0/answers/0/#{attr}")
          end
        end
      end
    end
  end

  describe 'GET /show' do
    # Указание ID "наживую", возможно, вызовет баги. Но по-другому без извращения с блоками before 
    # в ссылку его не вставить...
    let!(:question) { create(:question, id: 1) }
    let!(:attachments) { create_list(:attachment, 2, attachable_id: question.id, attachable_type: "Question") }
    let!(:comments) { create_list(:comment, 2, commentable_id: question.id, commentable_type: "Question") }
    # Чтобы не было проблем с сортировкой, берем через скоуп
    let!(:attachment) { question.attachments.first }
    let!(:comment) { question.comments.first }

    it_behaves_like 'unauthorized api', "/api/v1/questions/1"

    context 'authorized' do
      let(:access_token) { create(:doorkeeper_access_token) }

      before { get "/api/v1/questions/1", format: :json, access_token: access_token.token }

      it 'returns 200 status code' do
        expect(response).to be_success
      end

      %w(id title body created_at updated_at).each do |attr|
        it "question object contains #{attr}" do
          expect(response.body).to be_json_eql(question.send(attr.to_sym).to_json).at_path("question_show/#{attr}")
        end
      end

      context 'attachments' do
        it 'returns list of attachments' do
          expect(response.body).to have_json_size(2).at_path("question_show/attachments")
        end

        it 'returns id of attachment' do
          expect(response.body).to be_json_eql(attachment.id.to_json).at_path("question_show/attachments/0/id")
        end

        # Очень некрасиво, но никакие манипуляции с @request.host и host! не помогли
        it 'returns url of attachment' do
          expect(response.body).to be_json_eql("http://localhost:3000#{attachment.file.url}".to_json).at_path("question_show/attachments/0/url")
        end         
      end

      context 'comments' do
        it 'returns list of comments' do
          expect(response.body).to have_json_size(2).at_path("question_show/comments")
        end

        %w(id user_id body created_at updated_at).each do |attr|
          it "contains #{attr}" do
            expect(response.body).to be_json_eql(comment.send(attr.to_sym).to_json).at_path("question_show/comments/0/#{attr}")
          end
        end
      end
    end
  end
end 