require_relative '../spec_helper'

require 'fog/openstackcore'

describe "services" do
  describe "identity_v2" do

    let(:credentials_tenant_hash) {
      {
        :openstack_auth_url => "http://devstack.local:5000",
        :openstack_username => "admin",
        :openstack_api_key => "stack",
        :openstack_tenant => "admin",
        :openstack_region => "regionone"
      }
    }

    let(:credentials_hash) {
      {
        :openstack_auth_url => "http://devstack.local:5000",
        :openstack_username => "admin",
        :openstack_api_key => "stack",
        # :openstack_tenant => "admin",
        :openstack_region => "regionone"
      }
    }

    let(:auth_token_hash) {
      {
        :openstack_auth_url => "http://devstack.local:5000",
        :openstack_tenant => "admin",
        :openstack_region => "regionone",
        :openstack_auth_token => nil,
        # :service_options => {:proxy => 'http://localhost:8888'}
      }
    }

    describe "#initialize" do

      describe "#rescope_token" do

        describe "invalid auth token", :vcr do

          it "raises an Unauthorized exception" do
            auth_token_hash[:openstack_auth_token] = "invalid-token"
            proc {
              service =
                Fog::OpenStackCore::IdentityV2.new(auth_token_hash)
            }.must_raise Excon::Errors::Unauthorized
          end

        end

        describe "valid auth token", :vcr do

          # 1 - get a valid (unscoped) auth token
          let(:valid_token) {
            service = Fog::OpenStackCore::IdentityV2.new(credentials_hash)
            service.auth_token
          }

          # 2 - authenticate based on the valid auth token + tenant
          it "must not be nil" do
            hash = auth_token_hash.clone
            hash[:openstack_auth_token] = valid_token
            svc = Fog::OpenStackCore::IdentityV2.new(hash)

            svc.auth_token.wont_be_nil
          end
        end

      end  #rescope_token

      describe "#auth_with_credentials_and_tenant" do

        describe "with valid credentials", :vcr do

          let(:service) { Fog::OpenStackCore::IdentityV2.new(credentials_tenant_hash) }

          it "returns a service reference" do
            service.must_be_instance_of Fog::OpenStackCore::IdentityV2::Real
          end

          [ :service_catalog, :token, :auth_token, :unscoped_token,
            :current_tenant, :current_user ].each do |attrib|
            it { service.must_respond_to attrib }
          end

        end   # with valid credentials

        describe "with invalid credentials", :vcr do

          it "a missing url raises an ArgumentError" do
            invalid_options = credentials_tenant_hash.clone
            invalid_options[:openstack_auth_url] = nil

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise ArgumentError
          end

          it "a missing username raises an ArgumentError" do
            invalid_options = credentials_tenant_hash.clone
            invalid_options[:openstack_username] = nil

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise ArgumentError
          end

          it "a missing password/apikey raises an ArgumentError" do
            invalid_options = credentials_tenant_hash.clone
            invalid_options[:openstack_api_key] = nil

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise ArgumentError
          end

          it "an invalid username raises an Unauthorized exception" do
            invalid_options = credentials_tenant_hash
            invalid_options[:openstack_username] = "none"

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise Excon::Errors::Unauthorized
          end

          it "an invalid password raises an Unauthorized exception" do
            invalid_options = credentials_tenant_hash
            invalid_options[:openstack_api_key] = "none"

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise Excon::Errors::Unauthorized
          end

          it "an invalid tenant raises an Unauthorized exception" do
            invalid_options = credentials_tenant_hash
            invalid_options[:openstack_tenant] = "none"

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise Excon::Errors::Unauthorized
          end

        end # with invalid credentials

      end  #auth_with_credentials_and_tenant

      describe "#auth_with_credentials" do

        describe "with valid credentials", :vcr do

          let(:service) { Fog::OpenStackCore::IdentityV2.new(credentials_hash) }

          it "returns a service reference" do
            service.must_be_instance_of Fog::OpenStackCore::IdentityV2::Real
          end

          [ :service_catalog, :token, :auth_token, :unscoped_token,
            :current_tenant, :current_user ].each do |attrib|
            it { service.must_respond_to attrib }
          end

        end   # with valid credentials

        describe "with invalid credentials", :vcr do

          it "a missing url raises an ArgumentError" do
            invalid_options = credentials_hash.clone
            invalid_options[:openstack_auth_url] = nil

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise ArgumentError
          end

          it "a missing username raises an ArgumentError" do
            invalid_options = credentials_hash.clone
            invalid_options[:openstack_username] = nil

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise ArgumentError
          end

          it "a missing password/apikey raises an ArgumentError" do
            invalid_options = credentials_hash.clone
            invalid_options[:openstack_api_key] = nil

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise ArgumentError
          end

          it "an invalid username raises an Unauthorized exception" do
            invalid_options = credentials_hash.clone
            invalid_options[:openstack_username] = "none"

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise Excon::Errors::Unauthorized
          end

          it "an invalid password raises an Unauthorized exception" do
            invalid_options = credentials_hash.clone
            invalid_options[:openstack_api_key] = "none"

            proc {
              Fog::OpenStackCore::IdentityV2.new(invalid_options)
            }.must_raise Excon::Errors::Unauthorized
          end

        end # with invalid credentials

      end  #auth_with_credentials

    end # initialize

  end # identity
end # services



# Shindo.tests('OpenStack | authenticate', ['openstack']) do
#   begin
#     @old_mock_value = Excon.defaults[:mock]
#     Excon.defaults[:mock] = true
#     Excon.stubs.clear
#
#     expires      = Time.now.utc + 600
#     token        = Fog::Mock.random_numbers(8).to_s
#     tenant_token = Fog::Mock.random_numbers(8).to_s
#
#     body = {
#       "access" => {
#         "token" => {
#           "expires" => expires.iso8601,
#           "id"      => token,
#           "tenant"  => {
#             "enabled"     => true,
#             "description" => nil,
#             "name"        => "admin",
#             "id"          => tenant_token,
#           }
#         },
#         "serviceCatalog" => [{
#           "endpoints" => [{
#             "adminURL" =>
#               "http://example:8774/v2/#{tenant_token}",
#               "region" => "RegionOne",
#             "internalURL" =>
#               "http://example:8774/v2/#{tenant_token}",
#             "id" => Fog::Mock.random_numbers(8).to_s,
#             "publicURL" =>
#              "http://example:8774/v2/#{tenant_token}"
#           }],
#           "endpoints_links" => [],
#           "type" => "compute",
#           "name" => "nova"
#         },
#         { "endpoints" => [{
#             "adminURL"    => "http://example:9292",
#             "region"      => "RegionOne",
#             "internalURL" => "http://example:9292",
#             "id"          => Fog::Mock.random_numbers(8).to_s,
#             "publicURL"   => "http://example:9292"
#           }],
#           "endpoints_links" => [],
#           "type"            => "image",
#           "name"            => "glance"
#         }],
#         "user" => {
#           "username" => "admin",
#           "roles_links" => [],
#           "id" => Fog::Mock.random_numbers(8).to_s,
#           "roles" => [
#             { "name" => "admin" },
#             { "name" => "KeystoneAdmin" },
#             { "name" => "KeystoneServiceAdmin" }
#           ],
#           "name" => "admin"
#         },
#         "metadata" => {
#           "is_admin" => 0,
#           "roles" => [
#             Fog::Mock.random_numbers(8).to_s,
#             Fog::Mock.random_numbers(8).to_s,
#             Fog::Mock.random_numbers(8).to_s,]}}}
#
#     tests("v2") do
#       Excon.stub({ :method => 'POST', :path => "/v2.0/tokens" },
#                  { :status => 200, :body => Fog::JSON.encode(body) })
#
#       expected = {
#         :user                     => body['access']['user'],
#         :tenant                   => body['access']['token']['tenant'],
#         :identity_public_endpoint => nil,
#         :server_management_url    =>
#           body['access']['serviceCatalog'].
#             first['endpoints'].first['publicURL'],
#         :token                    => token,
#         :expires                  => expires.iso8601,
#         :current_user_id          => body['access']['user']['id'],
#         :unscoped_token           => token,
#       }
#
#       returns(expected) do
#         Fog::OpenStack.authenticate_v2(
#           :openstack_auth_uri     => URI('http://example/v2.0/tokens'),
#           :openstack_tenant       => 'admin',
#           :openstack_service_type => %w[compute])
#       end
#     end
#
#     tests("v2 missing service") do
#       Excon.stub({ :method => 'POST', :path => "/v2.0/tokens" },
#                  { :status => 200, :body => Fog::JSON.encode(body) })
#
#       raises(Fog::Errors::NotFound,
#              'Could not find service network.  Have compute, image') do
#         Fog::OpenStack.authenticate_v2(
#           :openstack_auth_uri     => URI('http://example/v2.0/tokens'),
#           :openstack_tenant       => 'admin',
#           :openstack_service_type => %w[network])
#       end
#     end
#
#     tests("v2 auth with two compute services") do
#       body_clone = body.clone
#       body_clone["access"]["serviceCatalog"] <<
#         {
#         "endpoints" => [{
#           "adminURL" =>
#             "http://example2:8774/v2/#{tenant_token}",
#             "region" => "RegionOne",
#           "internalURL" =>
#             "http://example2:8774/v2/#{tenant_token}",
#           "id" => Fog::Mock.random_numbers(8).to_s,
#           "publicURL" =>
#            "http://example2:8774/v2/#{tenant_token}"
#         }],
#         "endpoints_links" => [],
#         "type" => "compute",
#         "name" => "nova2"
#         }
#
#       Excon.stub({ :method => 'POST', :path => "/v2.0/tokens" },
#                  { :status => 200, :body => Fog::JSON.encode(body_clone) })
#
#       returns("http://example2:8774/v2/#{tenant_token}") do
#         Fog::OpenStack.authenticate_v2(
#           :openstack_auth_uri     => URI('http://example/v2.0/tokens'),
#           :openstack_tenant       => 'admin',
#           :openstack_service_type => %w[compute],
#           :openstack_service_name => 'nova2')[:server_management_url]
#       end
#
#     end
#
#     tests("legacy v1 auth") do
#       headers = {
#         "X-Storage-Url"   => "https://swift.myhost.com/v1/AUTH_tenant",
#         "X-Auth-Token"    => "AUTH_yui193bdc00c1c46c5858788yuio0e1e2p",
#         "X-Trans-Id"      => "iu99nm9999f9b999c9b999dad9cd999e99",
#         "Content-Length"  => "0",
#         "Date"            => "Wed, 07 Aug 2013 11:11:11 GMT"
#       }
#
#       Excon.stub({:method => 'GET', :path => "/auth/v1.0"},
#                  {:status => 200, :body => "", :headers => headers})
#
#       returns("https://swift.myhost.com/v1/AUTH_tenant") do
#         Fog::OpenStack.authenticate_v1(
#           :openstack_auth_uri     => URI('https://swift.myhost.com/auth/v1.0'),
#           :openstack_username     => 'tenant:dev',
#           :openstack_api_key      => 'secret_key',
#           :openstack_service_type => %w[storage])[:server_management_url]
#       end
#
#     end
#
#   ensure
#     Excon.stubs.clear
#     Excon.defaults[:mock] = @old_mock_value
#   end
# end
#
