require "govuk_sidekiq/sidekiq_initializer"

GovukSidekiq::SidekiqInitializer.setup_sidekiq(
  ENV.fetch("GOVUK_APP_NAME", "search-api"),
  { url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379") },
)
