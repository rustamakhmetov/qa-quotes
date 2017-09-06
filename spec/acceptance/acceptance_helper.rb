require 'rails_helper'

Capybara.server = :puma
Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium_chrome
Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
  config.use_transactional_fixtures = false

  config.before(:each, type: :feature) do
    # Note (Mike Coutermarsh): Make browser huge so that no content is hidden during tests
    Capybara.current_session.driver.browser.manage.window.resize_to(2_500, 2_500)
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, :sphinx => true) do
    # For tests tagged with Sphinx, use deletion (or truncation)
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end