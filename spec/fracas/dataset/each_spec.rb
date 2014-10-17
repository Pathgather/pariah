require 'spec_helper'

describe Fracas::Dataset, '#each' do
  it "should return the JSON documents matching the search" do
    store body: {title: "Title 1"}
    store body: {title: "Title 2"}
    FTS.refresh

    titles = []
    FTS.each do |doc|
      titles << doc['title']
    end
    titles.sort.should == ["Title 1", "Title 2"]
  end
end
