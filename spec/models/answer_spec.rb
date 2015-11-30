require 'rails_helper'

RSpec.describe Answer, type: :model do
  let (:question) { create(:question) }
  let (:answer) { create(:answer, question: question) }

  context "with validations" do
    it { should validate_presence_of :question_id }

    it { should validate_presence_of :body }
    it { should validate_length_of(:body).is_at_least(10).is_at_most 10.kilobytes }

    it { should belong_to(:question) }
    it { should belong_to(:user) }
  end

  # Ну не разбивать же на две спеки?..
  it "can switch best status" do
    answer.switch_promotion!
    expect(answer).to be_best
    answer.switch_promotion!
    expect(answer).not_to be_best
  end 

  it "can toggle best status between many answers" do
    other = create(:answer_multi, question: question)
    other.switch_promotion!
    answer.switch_promotion!
    expect(other.reload).not_to be_best
  end
end
