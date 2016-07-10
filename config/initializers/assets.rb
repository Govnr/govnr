# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
# Rails.application.config.assets.precompile += ['glyphicons-halflings-regular.*'] 
# Rails.application.config.assets.precompile += ['fontawesome-webfont.*']
# Rails.application.config.assets.precompile += ['fontawesome-webfont-v=4.2.0.*']
# Rails.application.config.assets.precompile += %w( .svg .eot .woff .woff2 .ttf .otf )
Rails.application.config.assets.precompile += %w( jquery/jquery.min.js )
Rails.application.config.assets.precompile += %w( metis_menu/metisMenu.min.js )
Rails.application.config.assets.precompile += %w( morris/morris.min.js )
Rails.application.config.assets.precompile += %w( morris/morris-data.js )
Rails.application.config.assets.precompile += %w( raphael/raphael.min.js )
Rails.application.config.assets.precompile += %w( sb-admin-2/sb-admin-2.js )
Rails.application.config.assets.precompile += %w( chart/Chart.bundle.min.js )