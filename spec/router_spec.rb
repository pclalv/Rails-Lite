require 'webrick'
require 'router'
require 'controller_base'

describe Router do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }

  before(:each) do
    allow(req).to receive(:request_method).and_return("GET")
  end

  describe "#add_route" do
    it "adds a route" do
      subject.add_route(1, 2, 3, 4)
      subject.routes.count.should == 1
      subject.add_route(1, 2, 3, 4)
      subject.add_route(1, 2, 3, 4)
      subject.routes.count.should == 3
    end
  end

  describe "#match" do
    it "matches a correct route" do
      subject.add_route(Regexp.new("^/users$"), :get, :x, :x)
      allow(req).to receive(:path).and_return("/users")
      matched = subject.match(req)
      matched.should_not be_nil
    end

    it "doesn't match an incorrect route" do
      subject.add_route(Regexp.new("^/users$"), :get, :x, :x)
      allow(req).to receive(:path).and_return("/incorrect_path")
      matched = subject.match(req)
      matched.should be_nil
    end
  end

  describe "#run" do
    it "sets status to 404 if no route is found" do
      subject.add_route(1, 2, 3, 4)
      allow(req).to receive(:path).and_return("/users")
      subject.run(req, res)
      res.status.should == 404
    end
  end

  describe "http method (get, put, post, delete)" do
    it "adds methods get, put, post and delete" do
      router = Router.new
      (router.methods - Class.new.methods).should include(:get)
      (router.methods - Class.new.methods).should include(:put)
      (router.methods - Class.new.methods).should include(:post)
      (router.methods - Class.new.methods).should include(:delete)
    end

    it "adds a route when an http method method is called" do
      router = Router.new
      router.get Regexp.new("^/users$"), ControllerBase, :index
      router.routes.count.should == 1
    end
  end
end
