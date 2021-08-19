FactoryBot.define do
  factory :bdd_<%= @klass.downcase %>, class: <%= @klass %> do<% @factory_args.each do |arg| %>
    <%= arg %><% end %>
  end
  <% if @related_models.size > 0 %>
      <% @related_models.each do |model_name| %>
        <%= model_name %> { build(:bdd_<%= model_name %>) }
      <% end %>
  <% end %>
end
