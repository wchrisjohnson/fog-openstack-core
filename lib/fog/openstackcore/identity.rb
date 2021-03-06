require 'fog/openstackcore/service_discovery'

module Fog
  module OpenStackCore

    # This is a proxy class for the Identity Service as a whole, irrespective of
    # what version is required.

    class Identity
      def self.new(options, connection_options = {})
        initialize_service(options, connection_options)
      end

      private

      def self.initialize_service(options, connection_options = {})
        opts = options.dup  # dup options so no wonky side effects
        opts.merge!(:connection_options => connection_options)

        ServiceDiscovery.new('openstackcore', 'identity', opts).call
      end

    end # Identity
  end # OpenStackCore
end # Fog
