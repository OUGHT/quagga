$("#question-edit-errors").html '<%= j render "shared/error_messages", object: @question %>'

<% if @question.errors.empty? %>
$('#question-content').html '<%= j render @question %>'
toggleQuestionForm()
<%= render partial: "shared/flash_messages_coffee.txt.erb" %>
<% end %>