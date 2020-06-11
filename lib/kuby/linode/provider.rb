require 'fileutils'

module Kuby
  module Linode
    class Provider < Kuby::Kubernetes::Provider
      KUBECONFIG_EXPIRATION = 7 * 24 * 60 * 60  # 7 days
      STORAGE_CLASS_NAME = 'linode-block-storage'.freeze

      attr_reader :config

      def configure(&block)
        config.instance_eval(&block)
      end

      def kubeconfig_path
        @kubeconfig_path ||= kubeconfig_dir.join(
          "#{definition.app_name.downcase}-kubeconfig.yaml"
        ).to_s
      end

      def after_configuration
        refresh_kubeconfig
      end

      def storage_class_name
        STORAGE_CLASS_NAME
      end

      private

      def after_initialize
        @config = Config.new
      end

      def client
        @client ||= Client.create(
          access_token: config.access_token
        )
      end

      def refresh_kubeconfig
        return unless should_refresh_kubeconfig?
        FileUtils.mkdir_p(kubeconfig_dir)
        Kuby.logger.info('Refreshing kubeconfig...')
        kubeconfig = client.kubeconfig(config.cluster_id)
        File.write(kubeconfig_path, kubeconfig)
        Kuby.logger.info('Successfully refreshed kubeconfig!')
      end

      def should_refresh_kubeconfig?
        !File.exist?(kubeconfig_path) ||
          (Time.now - File.mtime(kubeconfig_path)) >= KUBECONFIG_EXPIRATION
      end

      def kubeconfig_dir
        @kubeconfig_dir ||= definition.app.root.join(
          'tmp', 'kuby-linode'
        )
      end
    end
  end
end
