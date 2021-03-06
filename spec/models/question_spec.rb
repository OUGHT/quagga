require 'rails_helper'

RSpec.describe Question, type: :model do
  let (:user) { create(:user) }
  let (:question) { create(:question, user: user) }

  context "with validations" do
    it { should validate_presence_of :title }
    it { should validate_length_of(:title).is_at_least(5).is_at_most 150 }

    it { should validate_presence_of :body }
    it { should validate_length_of(:body).is_at_least(10).is_at_most 10.kilobytes }

    it { should have_many(:answers).dependent(:destroy) } 
    it { should have_many(:subscriptions).dependent(:destroy) } 
    it { should belong_to(:user) }
    it { should have_one(:best_answer).conditions(best: true).class_name(:Answer) } 
  end

  it_behaves_like "votable"
  it_behaves_like "attachable"
  it_behaves_like "commentable"

  it "can get best answer" do
    answer = create(:answer, question: question)
    answer.switch_promotion!
    expect(question.best_answer).to eq answer
  end

  # Некрасиво, не спорю. Но мне кажется, что дергать базу, создавая несколько объектов -
  # еще более некрасиво
  it "makes correct digest" do
    Timecop.freeze do
      expect(Question.digest.where_values.first).to match("created_at >= '#{1.day.ago.to_s(:db)}")
    end
  end

  it "should subscribe after create" do
    expect(question.subscriptions.first.user).to eq user
  end
end