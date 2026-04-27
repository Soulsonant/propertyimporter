source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.8"

gem "rails", "~> 7.1"
gem "pg", "~> 1.1"
gem "puma", "~> 8.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "csv-importer"
gem "kaminari"
gem "bootsnap", require: false
gem "csv"
gem "propshaft"
gem "ostruct"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "web-console"
end
