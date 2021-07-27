FactoryBot.define do
  factory :bdd_<%= @klass.downcase %>, class: <%= @klass %> do<% @factory_args.each do |arg| %>
    <%= arg %><% end %>
  end
end
