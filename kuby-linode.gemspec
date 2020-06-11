$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'kuby/linode/version'

Gem::Specification.new do |s|
  s.name     = 'kuby-linode'
  s.version  = ::Kuby::Linode::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/getkuby/kuby-linode'

  s.description = s.summary = 'Linode provider for Kuby.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'faraday', '~> 0.17'
  s.add_dependency 'kube-dsl', '~> 0.1'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'LICENSE', 'CHANGELOG.md', 'README.md', 'Rakefile', 'kuby-linode.gemspec']
end
