require 'webrick'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class EntreesController < ControllerBase
  ENTREES = [
    { id: 1, pasta_id: 1, text: "Fettuccine loves alfredo!" },
    { id: 2, pasta_id: 2, text: "Cavatelli, like my grandma's!" },
    { id: 3, pasta_id: 1, text: "Fettuccine alla Carbonara, how indulgent!" }
  ]

  def index
    @pasta = Pasta.all[params[:pasta_id].to_i - 1]
    @descriptions = ENTREES.select do |s|
      s[:pasta_id] == Integer(params[:pasta_id])
    end

    render :index
  end
end

class Pasta
  attr_reader :name, :id

  def self.all
    @pastas ||= []
  end

  def self.create(params)
    @pasta = Pasta.new(params)
    @pasta.save
  end

  def initialize(params = {})
    @name = params["name"]
  end

  def save
    return false unless @name.present?

    self.set_id

    Pasta.all << self
    true
  end

  def inspect
    { name: name, id: id }.inspect
  end

  protected

  def set_id
    @id = (Pasta.all.empty? ? 1 : Pasta.all.last.id + 1)
  end
end

Pasta.create({ "name" => "Fettuccine" })
Pasta.create({ "name" => "Cavatelli" })

class PastasController < ControllerBase

  def index
    @pastas = Pasta.all

    render :index
  end

  def new
    @pasta = Pasta.new

    render :new
  end

  def create
    @pasta = Pasta.new(params["pasta"])

    if @pasta.save
      redirect_to "/pastas"
    else
      render :new
    end
  end

end

router = Router.new
router.draw do
  get Regexp.new("^/pastas$"), PastasController, :index
  get Regexp.new("^/pastas/new$"), PastasController, :new
  post Regexp.new("^/pastas$"), PastasController, :create
  get Regexp.new("^/pastas/(?<pasta_id>\\d+)/entrees$"), EntreesController, :index
  get Regexp.new(""), PastasController, :index
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
