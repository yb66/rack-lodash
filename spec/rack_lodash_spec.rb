# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/rack/lodash.rb"

describe "The class methods" do
  let(:env) {
    {}
  }
  subject { Rack::Lodash.cdn env, opts }
  context "Given an argument" do
    context "of nil (the default)" do
      let(:opts) { {} }
      it { should == "<script src='#{Rack::Lodash::CDN::CLOUDFLARE}'></script>\n#{Rack::Lodash::FALLBACK}" }
    end
    context "of :jsdelivr" do
      let(:opts) { {organisation: :jsdelivr} }
      it { should == "<script src='#{Rack::Lodash::CDN::JSDELIVR}'></script>\n#{Rack::Lodash::FALLBACK}" }
    end
    context "of :cloudflare" do
      let(:opts) { {organisation: :cloudflare} }
      it { should == "<script src='#{Rack::Lodash::CDN::CLOUDFLARE}'></script>\n#{Rack::Lodash::FALLBACK}" }
    end
  end
end

describe "Inserting the CDN" do
  include_context "All routes"
  context "Check the examples run at all" do
    before do
      get "/"
    end
    it_should_behave_like "Any route"
  end
  context "jsDelivr CDN" do
    before do
      get "/jsdelivr-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:expected) { Rack::Lodash::CDN::JSDELIVR }
    it { should include expected }
  end
  context "Unspecified CDN" do
    before do
      get "/unspecified-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:expected) { Rack::Lodash::CDN::CLOUDFLARE }
    it { should include expected }
  end
  context "Cloudflare CDN" do
    before do
      get "/cloudflare-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:expected) { Rack::Lodash::CDN::CLOUDFLARE }
    it { should include expected }
  end
  context "Specified CDN via the use statement" do
    let(:app){ App2 }
    before do
      get "/"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:expected) { Rack::Lodash::CDN::JSDELIVR }
    it { should include expected }
  end
end


require 'timecop'
require 'time'

describe "Serving the fallback lodash" do
  include_context "All routes"
  before do
    get "/js/lodash-#{Rack::Lodash::LODASH_VERSION}.min.js"
  end
  it_should_behave_like "Any route"
  subject { last_response.body }
  let(:expected) { s = <<STR
/**
 * @license
 * Lo-Dash #{Rack::Lodash::LODASH_VERSION}
STR
    s.strip
  }
  it { should start_with expected }

  context "Re requests" do
    before do
      at_start = Time.parse(Rack::Lodash::LODASH_VERSION_DATE) + 60 * 60 * 24 * 180
      Timecop.freeze at_start
      get "/js/lodash-#{Rack::Lodash::LODASH_VERSION}.min.js"
      Timecop.travel Time.now + 86400 # add a day
      get "/js/lodash-#{Rack::Lodash::LODASH_VERSION}.min.js", {}, {"HTTP_IF_MODIFIED_SINCE" => Rack::Utils.rfc2109(at_start) }
    end
    subject { last_response }
    its(:status) { should == 304 }
  end
end