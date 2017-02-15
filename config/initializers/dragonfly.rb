require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick
  plugin :avatarmagick
  secret "2009aafb06e98a46a85e8438243e68f2df8e153c5ca9eff3fe0c54aa568ae16e"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
