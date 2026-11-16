# frozen_string_literal: true

require_relative "spec_helper"

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"

DUMMY_ROOT = Rails.root unless defined?(DUMMY_ROOT)

ActiveRecord::Base.connection_pool.with_connection do |connection|
  needed = %i[things admin_users active_admin_comments]
  next if needed.all? { |table| connection.table_exists?(table) }

  ActiveRecord::Schema.verbose = false
  load DUMMY_ROOT.join("db", "schema.rb").to_s
end

require "rspec/rails"
require "factory_bot"
require "capybara/rspec"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |path| require path }

Rails.application.reload_routes!
ActiveAdmin.application.load!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.filter_run_when_matching :focus
  config.order = :random
  Kernel.srand config.seed

  config.before do
    Thing.delete_all
    AdminUser.delete_all
  end
end

module AuthHelpers
  def sign_in(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def sign_out
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
  config.include AuthHelpers, type: :system
end

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |index| "admin-#{index}@rails.fi" }
    sequence(:name) { |index| "Admin #{index}" }
  end

  factory :thing do
    sequence(:name) { |index| "Thing #{index}" }
    sequence(:code) { |index| "C#{index}" }
  end
end
