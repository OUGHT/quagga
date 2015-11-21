require 'rails_helper'

RSpec.feature "QuestionsList", 
  %q{
    In order to seek help
    As an user
    I want to list questions
  },
  type: :feature do
  
  scenario "User can list questions" do
    user = create(:user)
    1.upto(30) { create(:question_multi, user: user) }
    visit questions_path

    # Тестируем с учетом пагинации и порядка
    30.downto(11) do |n| 
      within("div.question-row:nth-of-type(#{31-n})") do
        expect(page).to have_content "Question ##{n}"
      end
    end 
    10.downto(1) { |n| expect(page).not_to have_css "#question-#{n}" }

    click_link '2'
    10.downto(1) do |n| 
      within("div.question-row:nth-of-type(#{11-n})") do
        expect(page).to have_content "Question ##{n}"
      end
    end     
  end  
end
