Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = ENV.fetch('RAILS_CACHE_CLASSES', false)

  # Do not eager load code on boot.
  config.eager_load = ENV.fetch('RAILS_EAGER_LOAD_CODE', false)

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = {
    host: ENV.fetch("API_HOST_NAME", 'localhost:3000')

  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  #### OLD DEVELOPMENT CONFIG
  # # Debug mode disables concatenation and preprocessing of assets.
  # # This option may cause significant delays in view rendering with a large
  # # number of complex assets.
  # config.assets.debug = true

  # # Adds additional error checking when serving assets at runtime.
  # # Checks for improperly declared sprockets dependencies.
  # # Raises helpful error messages.
  # config.assets.raise_runtime_errors = true

  #### NEW DEVELOPMENT CONFIG
  config.serve_static_files = ENV.fetch('RAILS_SERVE_STATIC_FILES', true)

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'
  #### END NEW DEVELOPMENT CONFIG

  config.log_tags = [:uuid]

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

  # log to STDOUT if env var is set
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    # rails logger for reporting data on STDOUT
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
    # custom ActiveRecord(DB ORM) logger for avoiding noisy STDOUT logs
    log_file = File.open(Rails.root.join('log', 'development.log'), 'a')
    log_file.sync = true
    ActiveRecord::Base.logger = Logger.new(log_file)
  end
end
