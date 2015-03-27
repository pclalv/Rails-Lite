require 'webrick'
require 'route'

describe Route do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }

  before(:each) do
    allow(req).to receive(:request_method).and_return("GET")
  end

  describe "#matches?" do
    it "matches simple regular expression" do
      index_route = Route.new(Regexp.new("^/users$"), :get, "x", :x)
      allow(req).to receive(:path).and_return("/users")
      index_route.matches?(req).should be true
    end

    it "matches regular expression with capture" do
      index_route = Route.new(Regexp.new("^/users/(?<id>\\d+)$"), :get, "x", :x)
      allow(req).to receive(:path).and_return("/users/1")
      index_route.matches?(req).should be true
    end

    it "correctly doesn't matche regular expression with capture" do
      index_route = Route.new(Regexp.new("^/users/(?<id>\\d+)$"), :get, "UsersController", :index)
      allow(req).to receive(:path).and_return("/statuses/1")
      index_route.matches?(req).should be false
    end
  end

  describe "#run" do
    before(:all) { class DummyController; end }
    after(:all) { Object.send(:remove_const, "DummyController") }

    it "instantiates controller and invokes action" do
      # reader beware. hairy adventures ahead.
      # this is really checking way too much implementation,
      # but tests the aproach recommended in the project
      allow(req).to receive(:path).and_return("/users")

      dummy_controller_class = DummyController
      dummy_controller_instance = DummyController.new
      dummy_controller_instance.stub(:invoke_action)
      dummy_controller_class.stub(:new).with(req, res, {}) { dummy_controller_instance }
      dummy_controller_class.stub(:new).with(req, res) { dummy_controller_instance }
      dummy_controller_instance.should_receive(:invoke_action)
      index_route = Route.new(Regexp.new("^/users$"), :get, dummy_controller_class, :index)
      index_route.run(req, res)
    end
  end
end
