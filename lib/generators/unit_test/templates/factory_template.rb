FactoryBot.define do
  factory :bdd_<%= @klass.downcase %>, class: <%= @klass %> do<% @factory_args.each do |arg| %>
    <%= arg %><% end %>
    <% if @related_models.size > 0 %>
    <% @related_models.each do |elem| %>
      trait :with_<%= elem[:association]%> do
        association :<%= elem[:association] %>, factory: :bdd_<%= elem[:model].to_s.downcase %>
      end
      <% end %>
    <% end %>
  end
end
