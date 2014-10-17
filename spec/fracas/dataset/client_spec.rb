require 'spec_helper'

describe Fracas::Dataset, '#client' do
  it "should return the ElasticSearch client object used by that Dataset object" do
    FTS.client.should be_an_instance_of Elasticsearch::Transport::Client
    proc { FTS.client.info }.should_not raise_error
  end
end
