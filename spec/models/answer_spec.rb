require 'rails_helper'

RSpec.describe Answer, type: :model do
  let (:answer) { build(:answer) }

  context "with validations" do
    it { should validate_presence_of :question_id }

    it { should validate_presence_of :body }
    it { should validate_length_of(:body).is_at_least(10).is_at_most 10.kilobytes }

    it { should belong_to(:question) }
  end
end