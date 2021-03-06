module Fog
  module OpenStackCore
    class IdentityV2
      class Real

        def get_tenants_by_id(tenant_id)
          admin_request(
            :method   => 'GET',
            :expects  => [200, 204],
            :path     => "/v2.0/tenants/#{tenant_id}",
          )
        end

      end

      class Mock
      end
    end # IdentityV2
  end # OpenStackCore
end # Fog
