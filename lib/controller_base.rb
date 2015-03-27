require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './params'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @already_built_response = false
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  def render(template_name)
    template_file = File.read("views/#{controller_name}/#{template_name.to_s}.html.erb")
    template = ERB.new(template_file)
    content = template.result(binding)

    render_content(content, 'text/html')
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    if @already_built_response
      raise 'error'
    else
      @res['location'] = url
      @res.status = 302
      @already_built_response = true
    end

    session.store_session(res)
  end

  def render_content(content, content_type)
    if already_built_response?
      raise 'error'
    else
      @res.content_type, @res.body = content_type, content
      @already_built_response = true
    end

    session.store_session(res)
  end

  def controller_name
    self.class.name.underscore
  end

  def session
    @session ||= Session.new(req)
  end

  def invoke_action(name)
    self.send(name)

    render(name) unless already_built_response?
  end
end
