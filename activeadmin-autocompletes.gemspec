# frozen_string_literal: true

require_relative "lib/activeadmin/autocompletes/version"

Gem::Specification.new do |spec|
  spec.name = "activeadmin-autocompletes"
  spec.version = ActiveAdmin::Autocompletes::VERSION
  spec.authors = ["Andrei Makarov"]
  spec.email = ["contact@kiskolabs.com"]

  spec.summary = "Lazy REST autocomplete inputs and filters for ActiveAdmin"
  spec.description = "ActiveAdmin-only support for lazy and extensible, fully configurable autocompletes for filters and inputs. Collection-action JSON options, Formtastic filter/form inputs, Stimulus typeahead, and multi-select chips."
  spec.license = "MIT"
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 3.4.0"

  repository_url = "https://github.com/amkisko/activeadmin-autocompletes.rb"

  spec.homepage = repository_url
  spec.metadata = {
    "homepage_uri" => repository_url,
    "source_code_uri" => "#{repository_url}/tree/main",
    "changelog_uri" => "#{repository_url}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{repository_url}/issues",
    "documentation_uri" => "#{repository_url}#readme",
    "allowed_push_host" => "https://rubygems.org",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.chdir(__dir__) do
    %w[
      CHANGELOG.md
      CODE_OF_CONDUCT.md
      CONTRIBUTING.md
      GOVERNANCE.md
      LICENSE.md
      README.md
      SECURITY.md
      activeadmin-autocompletes.gemspec
    ].select { |path| File.file?(path) } +
      Dir["{app,config,lib,sig}/**/*"]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "activeadmin", ">= 4.0.0.beta23", "< 5"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "rails", ">= 7.2.3.2"

  spec.add_development_dependency "appraisal", "~> 2"
  spec.add_development_dependency "bundler", ">= 2"
  spec.add_development_dependency "bundler-audit", "~> 0.9"
  spec.add_development_dependency "polyrun", ">= 3.0.0"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "rbs", "~> 4"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "rspec-rails", ">= 6"
  spec.add_development_dependency "sqlite3", ">= 2.10.2"
  spec.add_development_dependency "rubocop-rspec", "~> 3.8"
  spec.add_development_dependency "rubocop-thread_safety", "~> 0.7"
  spec.add_development_dependency "standard", "~> 1.52"
  spec.add_development_dependency "standard-custom", "~> 1.0"
  spec.add_development_dependency "standard-performance", "~> 1.8"
  spec.add_development_dependency "standard-rspec", "~> 0.3"
end
