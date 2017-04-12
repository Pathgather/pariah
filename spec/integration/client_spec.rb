# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, '#client' do
  it "should return the ElasticSearch client object used by that Dataset object" do
    assert_instance_of Elasticsearch::Transport::Client, FTS.client
    FTS.client.info # Doesn't raise error
  end
end
