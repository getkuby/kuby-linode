$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'kuby/linode/version'

Gem::Specification.new do |s|
  s.name     = 'kuby-linode'
  s.version  = ::Kuby::Linode::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/camertron/kuby-linode'

  s.description = s.summary = 'Linode provider for Kuby.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'kuby', '~> 1.0'
  s.add_dependency 'faraday', '~> 0.17'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'CHANGELOG.md', 'README.md', 'Rakefile', 'kuby-linode.gemspec']
end
