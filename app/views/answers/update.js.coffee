<% if @answer.errors.empty? %>
$('#answer-<%= @answer.id %>').html '<%= j render @answer %>'
bindToggleAnswerForms()
<%= render partial: "shared/flash_messages_coffee.txt.erb" %>
<% else %>
$('#answer-edit-errors-<%= @answer.id %>').html '<%= j render "shared/error_messages", object: @answer %>'
<% end %>