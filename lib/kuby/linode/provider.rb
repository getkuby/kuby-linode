require 'colorized_string'
require 'fileutils'

module Kuby
  module Linode
    class Provider
      KUBECONFIG_EXPIRATION = 7.days

      attr_reader :definition, :config

      def initialize(definition)
        @definition = definition
        @config = Config.new
      end

      def configure(&block)
        config.instance_eval(&block)
      end

      def setup
        # no setup steps :)
      end

      def deploy
        deployer.deploy
      end

      def kubernetes_cli
        @kubernetes_cli ||= Kuby::Kubernetes::CLI.new(kubeconfig_path).tap do |cli|
          cli.before_execute do
            FileUtils.mkdir_p(kubeconfig_dir)
            refresh_kubeconfig
          end
        end
      end

      def kubeconfig_path
        @kubeconfig_path ||= kubeconfig_dir.join(
          "#{definition.app_name.downcase}-kubeconfig.yaml"
        )
      end

      private

      def client
        @client ||= Client.create(
          access_token: config.access_token
        )
      end

      def deployer
        @deployer ||= Kuby::Kubernetes::Deployer.new(
          definition.kubernetes.resources, kubernetes_cli
        )
      end

      def refresh_kubeconfig
        return unless should_refresh_kubeconfig?
        Kuby.logger.info(ColorizedString['Refreshing kubeconfig...'].yellow)
        kubeconfig = client.kubeconfig(config.cluster_id)
        File.write(kubeconfig_path, kubeconfig)
        Kuby.logger.info(ColorizedString['Successfully refreshed kubeconfig!'].yellow)
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
