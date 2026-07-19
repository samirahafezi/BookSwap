require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Rails.cache is :memory_store in test (see config/environments/test.rb, needed so
    # SessionsController's rate_limit can actually be exercised). MemoryStore is
    # process-global and never resets on its own, so without this, rate-limit counters
    # accumulate across unrelated tests sharing a parallel-test worker process and can
    # eventually rate-limit otherwise-valid logins in tests that never touch rate
    # limiting themselves.
    setup { Rails.cache.clear }

    # Add more helper methods to be used by all tests here...
  end
end
