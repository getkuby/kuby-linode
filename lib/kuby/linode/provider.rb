require 'fileutils'
require 'tmpdir'

module Kuby
  module Linode
    class Provider < Kuby::Kubernetes::Provider
      KUBECONFIG_EXPIRATION = 7 * 24 * 60 * 60  # 7 days
      STORAGE_CLASS_NAME = 'linode-block-storage-retain'.freeze

      attr_reader :config

      def configure(&block)
        config.instance_eval(&block) if block
      end

      def kubeconfig_path
        @kubeconfig_path ||= File.join(
          kubeconfig_dir,
          "#{environment.app_name.downcase}-#{config.hash_value}-kubeconfig.yaml"
        )
      end

      def before_setup
        refresh_kubeconfig
      end

      def before_deploy(*)
        refresh_kubeconfig
      end

      def storage_class_name
        STORAGE_CLASS_NAME
      end

      def kubernetes_cli
        @kubernetes_cli ||= ::KubernetesCLI.new(kubeconfig_path).tap do |cli|
          cli.before_execute do
            refresh_kubeconfig
          end
        end
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
        @kubeconfig_dir ||= File.join(
          Dir.tmpdir, 'kuby-linode'
        )
      end
    end
  end
end
