require 'kuby'
require 'kuby/linode/provider'

module Kuby
  module Linode
    autoload :Client, 'kuby/linode/client'
    autoload :Config, 'kuby/linode/config'
  end
end

Kuby.register_provider(:linode, Kuby::Linode::Provider)
