require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  context "#aggregate" do
    before do
      @categories = ["sit", "blanditiis", "omnis", "est", "nam"]
      @user_names = ["Elyse Doyle Jr.", "Keely Simonis III", "Estevan Sipes", "Lisa Kris", "Leora Kris"]
      @companies  = ["Dietrich-Quitzon", "Schoen-Kunze", "Hudson Inc", "Toy-Bergnaum", "Predovic Inc"]

      store_bodies 100.times.map {
        {
          category:  @categories.sample,
          user_name: @user_names.sample,
          company:   @companies.sample,
        }
      }
    end

    it "specifies a list of fields to aggregate on" do
      ds = FTS[:pariah_test_default]
      results = ds.aggregate(:category, :user_name, :company).load

      categories = results.aggregates[:category][:buckets]
      categories.map{|c| c[:key]}.sort.should == ["sit", "blanditiis", "omnis", "est", "nam"].sort
      categories.inject(0){|total, c| total + c[:doc_count]}.should == 100
    end
  end
end
