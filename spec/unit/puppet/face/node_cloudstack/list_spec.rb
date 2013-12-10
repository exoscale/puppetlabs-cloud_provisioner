require 'spec_helper'

describe 'puppet node_cloudstack list' do

  subject { Puppet::Face[:node_cloudstack, :current] }

  describe 'option validation' do
    context 'without any options' do
     it 'should require kind' do
        pattern = /wrong number of arguments/
        expect { subject.list }.to raise_error ArgumentError, pattern
      end
    end

    context 'with invalid kind' do
      
      let(:kind) { 'images' }
      it 'should require a valid kind' do
        pattern = /kind must be one of/
        expect { subject.list(:kind) }.to raise_error ArgumentError, pattern
      end
    end
  end

  describe 'the default behaviour of list' do
    
    before :each do
      Puppet::CloudPack::CloudStack.any_instance.stubs(:create_connection).returns(model)
    end


    context 'when kind is images' do

      let(:model) do
        mock('Fog::Compute[:Cloudstack]') do
          expects(:list_templates).returns(self)
        end
      end

      it 'should set kind to images' do
        subject.list('images')[:kind].should == 'iimages'
      end
    end
  end
end
