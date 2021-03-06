require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let (:user) { create(:user) }
  let (:question) { create(:question, user: user) }
  let (:answer) { create(:answer, user: user, question: question) }

  it_behaves_like "voted" do
    def patch_vote(votable, direction)
      patch :vote, id: votable.id, question_id: votable.question.id, direction: direction, format: :json
    end
  end

  describe 'GET #show' do
    before(:each) { get :show, id: answer, question_id: question }

    it "assigns the requested answer to @answer" do     
      expect(assigns(:answer)).to eq answer
    end

    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe 'POST #create' do
    context 'when logged in' do
      before(:each) { log_in_as user }

      context 'with valid attributes' do
        it "adds @question to @answer parents" do
          expect {
            post :create, answer: attributes_for(:answer), question_id: question, format: :js
          }.to change(question.answers, :count).by 1
        end

        it "adds @user to @answer parents" do
          expect {
            post :create, answer: attributes_for(:answer), question_id: question, format: :js
          }.to change(user.answers, :count).by 1
        end

        it "renders js :create" do
          post :create, answer: attributes_for(:answer), question_id: question, format: :js
          expect(response).to render_template :create
        end

        it "sends email to subscribers" do
          expect do
            post :create, answer: attributes_for(:answer), question_id: question, format: :js
          end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by 1
        end
      end

      context 'with invalid attributes' do
        it "does not save the new answer to database" do
          question
          expect {
            post :create, answer: attributes_for(:answer_invalid), question_id: question, format: :js
          }.not_to change(Answer, :count)
        end

        it "renders js :create" do
          post :create, answer: attributes_for(:answer_invalid), question_id: question, format: :js
          expect(response).to render_template :create
        end

        it "shows error message" do
          post :create, answer: attributes_for(:answer_invalid), question_id: question, format: :js
          expect(assigns(:answer).errors).not_to be_empty
        end 

        it "does not send email to subscribers" do
          expect do
            post :create, answer: attributes_for(:answer_invalid), question_id: question, format: :js
          end.not_to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size)
        end 
      end
    end

    context 'when logged out' do
      it "does not save the new answer to database" do
        question
        expect {
          post :create, answer: attributes_for(:answer_invalid), question_id: question, format: :js
        }.not_to change(Answer, :count)
      end   
    end
  end

  describe 'PATCH #update' do  
    shared_examples_for 'not changing answer' do
      it 'does not change body' do
        answer.reload
        expect(answer.body).to eq attributes_for(:answer)[:body]         
      end     
    end

    describe 'when logged in' do
      context 'as correct user' do
        before(:each) { log_in_as user }

        context 'with valid attributes' do
          before(:each) { patch :update, id: answer.id, question_id: question.id, format: :js, 
                          answer: { body: "A very special answer" } }
        
          it "assigns correct Question to @question" do
            expect(assigns(:question)).to eq question
          end

          it "assigns correct Answer to @answer" do
            expect(assigns(:answer)).to eq answer
          end

          it "changes body for @answer" do
            answer.reload
            expect(answer.body).to eq "A very special answer"
          end

          it "renders the :update template" do
            expect(response).to render_template :update
          end           
        end
        
        context 'with invalid attributes' do
          before(:each) { patch :update, id: answer.id, question_id: question.id, format: :js, 
                          answer: { body: "" } }

          it_behaves_like 'not changing answer'
        end
      end

      context 'as incorrect user' do
        let (:other) { create(:user_multi) }
        before(:each) { log_in_as other }
        before(:each) { patch :update, id: answer.id, question_id: question.id, format: :js, 
                        answer: { body: "A very special answer" } }

        it_behaves_like 'not changing answer'
      end
    end

    context 'when logged out' do
      before(:each) { patch :update, id: answer.id, question_id: question.id, format: :js, 
                      answer: { body: "A very special answer" } }
                
      it_behaves_like 'not changing answer'   
    end    
  end

  describe 'DELETE #destroy' do
    shared_examples_for 'not deleting answer' do
      it "does not delete answer" do
        answer
        expect {
          delete :destroy, id: answer.id, question_id: question.id, format: :js
        }.not_to change(Answer, :count)
      end 
    end

    context 'when logged in' do
      context 'as correct user' do
        before(:each) { log_in_as user }

        it 'deletes the question' do
          answer
          expect {
            delete :destroy, id: answer.id, question_id: question.id, format: :js
          }.to change(Answer, :count).by -1
        end   

        it "renders the :destroy template"  do
          delete :destroy, id: answer.id, question_id: question.id, format: :js
          expect(response).to render_template :destroy
        end
      end

      context 'as incorrect user' do
        let (:other) { create(:user_multi) }
        before(:each) { log_in_as other }

        it_behaves_like 'not deleting answer'
      end
    end

    context 'when logged out' do
      it_behaves_like 'not deleting answer'
    end
  end

  describe 'PATCH #switch_promotion' do  
    shared_examples_for 'not switching answer' do
      it 'does not become best' do
        patch :switch_promotion, id: answer.id, question_id: question.id, format: :js
        answer.reload
        expect(answer).not_to be_best
      end    

      it 'does not become normal' do
        answer.switch_promotion!
        patch :switch_promotion, id: answer.id, question_id: question.id, format: :js
        answer.reload
        expect(answer).to be_best
      end   
    end

    describe 'when logged in' do
      context 'as correct user' do
        before(:each) { log_in_as user }
      
        it "assigns correct Question to @question" do
          patch :switch_promotion, id: answer.id, question_id: question.id, format: :js
          expect(assigns(:question)).to eq question
        end

        it "assigns correct Answer to @answer" do
          patch :switch_promotion, id: answer.id, question_id: question.id, format: :js
          expect(assigns(:answer)).to eq answer
        end

        it "renders the :switch_promotion template" do
          patch :switch_promotion, id: answer.id, question_id: question.id, format: :js
          expect(response).to render_template :switch_promotion
        end   

        it "changes to best answer for @question" do
          patch :switch_promotion, id: answer.id, question_id: question.id, format: :js
          answer.reload
          expect(answer).to be_best
        end       

        it "changes best answer to normal for @question" do
          answer.switch_promotion!
          patch :switch_promotion, id: answer.id, question_id: question.id, format: :js
          answer.reload
          expect(answer).not_to be_best
        end 
      end

      context 'as incorrect user' do
        let (:other) { create(:user_multi) }
        before(:each) { log_in_as other }

        it_behaves_like 'not switching answer'
      end
    end

    context 'when logged out' do
      it_behaves_like 'not switching answer'
    end    
  end  
end
