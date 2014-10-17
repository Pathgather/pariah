require 'spec_helper'

describe Fracas::Cluster, '#client' do
  it "should return the ElasticSearch client object used by that Cluster object" do
    FTS.client.should be_an_instance_of Elasticsearch::Transport::Client
    proc { FTS.client.info }.should_not raise_error
  end
end
