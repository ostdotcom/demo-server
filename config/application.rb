require_relative 'boot'

require "rails"

# Include each railties manually
%w(
  active_record/railtie
  active_model/railtie
  action_controller/railtie
  action_mailer/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end


require "#{File.expand_path('../..', __FILE__)}/lib/global_constant/base.rb"
Dir["#{File.expand_path('../..', __FILE__)}/lib/global_constant/*.rb"].each {|file| require file }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DemoServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Local machine timezone
    config.time_zone = YAML.load_file(open(Rails.root.to_s + '/config/time_zone.yml'))['rails_time_zones'][Rails.env.to_s]
    # Local machine timezone
    config.active_record.default_timezone = :local

    # Use cache store
    config.cache_store = :dalli_store, GlobalConstant::Cache.endpoints, GlobalConstant::Cache.config

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << "#{config.root}/lib/"
    config.eager_load_paths << "#{config.root}/lib/"

    # Custom Error response
    config.exceptions_app = self.routes

    # Exception notification
    config.middleware.use ExceptionNotification::Rack,
                          email: {
                            email_prefix: "Platform Demo #{Rails.env} ::",
                            sender_address: ENV["DEMO_EXCEPTION_NOTIFICATION_FROM"],
                            exception_recipients: ENV["DEMO_EXCEPTION_NOTIFICATION_TO"]
                          },
                          ignore_exceptions: ExceptionNotifier.ignored_exceptions
  end
end
