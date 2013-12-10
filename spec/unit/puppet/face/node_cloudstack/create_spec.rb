require 'spec_helper'

describe 'puppet node_cloudstack create' do

  subject { Puppet::Face[:node_cloudstack, :current] }

  server_attributes = {
    :id        => 'e51f8131-ea94-44a4-b9e9-ed9da1064445',
    :name      => 'server123456',
  }

  describe 'option validation' do
    context 'without any options' do
     it 'should require flavor_id' do
        pattern = /are required.+?flavor_id/
        expect { subject.create }.to raise_error ArgumentError, pattern
      end

      it 'should require image_id' do
        pattern = /are required.+?image_id/
        expect { subject.create }.to raise_error ArgumentError, pattern
      end

      it 'shopuld require zone_id' do
        pattern = /are required.+?image_id/
        expect { subject.create }.to raise_error ArgumentError, pattern
      end
    end
  end

  describe 'the behavior of create' do
    before :each do
      Puppet::CloudPack::CloudStack.any_instance.stubs(:create_connection).returns(server)
    end

    let(:server) do
      mock('Fog::Compute[:Cloudstack]') do
        expects(:servers).returns(self)
        expects(:create).returns(self)
        expects(:attributes).returns(server_attributes)
        expects(:images).returns(self)
        expects(:zones).returns(self)
        expects(:flavors).returns(self)
      #  expects(:get).times(3).returns(self)
        expects(:ready?).returns(true)
        expects(:wait_for).with { ready? }
      end
    end

    context 'with only required arguments' do
      let(:options) do
        { :image_id  => '1d961c82-7c8c-4b84-b61b-601876dab8d0', 
          :flavor_id => 'a216b0d1-370f-4e21-a0eb-3dfc6302b564', 
          :zone_id   => '1128bd56-b4d9-4ac6-a7b9-c715b187ce11',
        }
      end

      it 'should create a server' do
        expected_attributes = {
          :id        => 'e51f8131-ea94-44a4-b9e9-ed9da1064445',
          :name      => 'server123456',
          :status    => 'success',
        }
        subject.create(options).should == [expected_attributes]
      end
    end

    context 'when --wait-for-boot is false' do
      let(:server) do
        mock('Fog::Compute[:Cloudstack]') do
          expects(:servers).returns(self)
          expects(:create).returns(self)
          expects(:images).returns(self)
          expects(:zones).returns(self)
          expects(:flavors).returns(self)
          expects(:get).times(3).returns(self)
          expects(:attributes).returns(server_attributes)
          expects(:ready?).never
          expects(:wait_for).never
        end
      end

      let(:options) do
        { :image_id  => '1d961c82-7c8c-4b84-b61b-601876dab8d0', 
          :flavor_id => 'a216b0d1-370f-4e21-a0eb-3dfc6302b564', 
          :zone_id   => '1128bd56-b4d9-4ac6-a7b9-c715b187ce11',
          :wait_for_boot => false
        }
      end

      it 'should wait for the server to boot' do
        subject.create(options)
      end
    end

    context 'when --wait-for-boot is false' do
      let(:server) do
        mock('Fog::Compute[:cloudstack]') do
          expects(:servers).returns(self)
          expects(:create).returns(self)
          expects(:attributes).returns(server_attributes)
          expects(:images).returns(self)
          expects(:zones).returns(self)
          expects(:flavors).returns(self)
          expects(:get).times(3).returns('')
          expects(:ready?).never
          expects(:wait_for).never
        end
      end

      let(:options) do
        { :image_id  => '1d961c82-7c8c-4b84-b61b-601876dab8d0',
          :flavor_id => 'a216b0d1-370f-4e21-a0eb-3dfc6302b564',
          :zone_id   => '1128bd56-b4d9-4ac6-a7b9-c715b187ce11',
          :wait_for_boot => false
        }

    end

      it 'should not wait for the server to boot' do
        subject.create(options)
      end
    end
  end

  describe 'inline documentation' do
    subject { Puppet::Face[:node_cloudstack, :current].get_action :create }

    its(:summary)     { should =~ /create.*Cloudstack/im }
    its(:description) { should =~ /launches.*Cloudstack/im }
    its(:examples)    { should_not be_empty }

    %w{ license copyright summary description returns examples }.each do |doc|
      context "of the" do
        its(doc.to_sym) { should_not =~ /(FIXME|REVISIT|TODO)/ }
      end
    end
  end
end
