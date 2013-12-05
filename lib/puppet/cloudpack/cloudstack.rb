require 'puppet/cloudpack'

# This is a container for various horrible procedural code used to set up the
# face actions for the `node_gce` face.  It lives here because the design of
# faces -- reinventing the Ruby object model, poorly -- makes it impossible to
# do standard things such as module inclusion, or inheritance, that would
# normally solve these problems in a real OO system.
module Puppet::CloudPack

  class CloudStack

    attr_accessor :connection

    def initialize(options, connection=nil)
      @options    = options
      @connection = connection || create_connection
    end

    def create_connection(options = {})
      Puppet.notice("Connecting to Cloudstack....")
      connection = Fog::Compute[:Cloudstack]
      Puppet.notice("Connected.")
      connection
    end

    def list
      servers = @connection.servers
      # Convert the Fog object into a simple hash.
      # And return the array to the Faces API for rendering
      if servers.empty?
        s = {}
      else
        s = servers.collect {|s| s.attributes}
      end
      s
    end

    def create(options)
      create_options = {
        :image_id      => options[:image_id],
        :flavor_id     => options[:flavor_id],
        :zone_id       => options[:zone_id],
      } 
      @connection.servers.create(create_options)
    end


    def options(to, *which)
      which.each do |name|
        send("add_#{name}_option", to)
      end
    end

    def add_zone_option(action, with_default = true)
      action.option '--zone CH2' do
        summary 'Limit to instances in the specified zone'
        with_default and default_to { '1128bd56-b4d9-4ac6-a7b9-c715b187ce11' }
      end
    end

    def add_provider_option(action, with_default = true)
       action.option '--provider Cloudstack' do
        summary 'Fog provider'
        with_default and default_to { 'Cloudstack' }
       end
    end



    def add_image_option(action)
      action.option '--image <name>' do
        summary 'Template to use to create the instance'
        description <<-EOT
            The pre-configured operating system image to use when creating this
            machine instance. 
        EOT
        required
        before_action do |action, args, options|
      #    if Puppet::CloudPack.create_connection(options).images.get(options[:image]).nil?
          #if create_connection(options).images.get(options[:image]).nil?
      #      raise ArgumentError, "Unrecognized image name: #{options[:image]}"
          end
        end
      end
    end
  end
