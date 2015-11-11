FactoryGirl.define do
  factory :answer do
    question
    body "If you can unwrap it from the module, simply place it at 'app/something/class.rb'.\nHope this helps."
    factory :answer_invalid do
      body ""
    end
  end

end