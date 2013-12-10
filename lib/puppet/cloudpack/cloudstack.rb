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
      connection = Fog::Compute[:Cloudstack]
    end

    def list_servers
      servers = @connection.servers
      # Convert the Fog object into a simple hash.
      # And return the array to the Faces API for rendering
      if servers.empty?
        s = {}
      else
        s = servers.collect {|s| s.attributes}
      end
      { :kind => @options[:kind], :servers => s }
    end

    def list_zones
      zones = @connection.zones
      # Convert the Fog object into a simple hash.
      # And return the array to the Faces API for rendering
      if zones.empty?
        z = {}
      else
        z = zones.collect {|z| z.attributes}
      end
      { :kind => @options[:kind], :zones => z }
     end

    def list_flavors
      flavors = @connection.flavors
      # Convert the Fog object into a simple hash.
      # And return the array to the Faces API for rendering
      if flavors.empty?
        f = {}
      else
        f = flavors.collect {|f| f.attributes}
      end
      { :kind => @options[:kind], :flavors => f }
    end

    def list_images
      images = @connection.list_templates( { :templatefilter => 'executable' } )
      { :kind =>  @options[:kind], :images => images }
    end

    def create(options)
      create_options = {
        :image_id      => options[:image_id],
        :flavor_id     => options[:flavor_id],
        :zone_id       => options[:zone_id],
        :name          => options[:server_name],
      } 
      server = @connection.servers.create(create_options)

      if @options[:wait_for_boot]
        Puppet.notice "Waiting for server to boot ..."
        server.wait_for { ready? }
      end

      # TODO: Retrieve password from job. jobresult = @connection.jobs.get(server.attributes["jobid"]);
      [{:status => 'success' }.merge(server.attributes)]

    end

    

  end
end
