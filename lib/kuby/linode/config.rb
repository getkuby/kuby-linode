module Kuby
  module Linode
    class Config
      extend Kuby::ValueFields

      value_fields :access_token, :cluster_id
    end
  end
end
