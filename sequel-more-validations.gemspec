# frozen_string_literal: true

require_relative "lib/sequel/plugins/more_validations"

Gem::Specification.new do |s|
  s.name = "sequel-more-validations"
  s.version = Sequel::Plugins::MoreValidations::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = "Extra validations for Ruby Sequel models."
  s.author = "Lithic Tech"
  s.email = "hello@lithic.tech"
  s.homepage = "https://github.com/lithictech/sequel-more-validations"
  s.licenses = "MIT"
  s.required_ruby_version = ">= 2.7.0"
  s.description = <<~DESC
    sequel-more-validations is a Sequel model plugin that provides common helplful validations.
  DESC
  s.metadata["rubygems_mfa_required"] = "true"
  s.files = Dir["lib/**/*.rb"]
  s.add_development_dependency("rspec", "~> 3.10")
  s.add_development_dependency("rspec-core", "~> 3.10")
  s.add_development_dependency("rubocop", "~> 1.11")
  s.add_development_dependency("rubocop-performance", "~> 1.10")
  s.add_development_dependency("rubocop-sequel", "~> 0.2")
  s.add_development_dependency("sequel", "~> 5.0")
  s.add_development_dependency("sqlite3", "~> 1")
end
