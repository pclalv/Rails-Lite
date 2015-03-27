class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    return false unless pattern.is_a? Regexp

    !!(req.path.match(pattern) && req.request_method.downcase.to_sym == http_method)
  end

  def run(req, res)
    match_data = req.path.match(pattern)
    keys = match_data.names.map
    vals = match_data.captures
    route_params = keys.zip(vals).to_h

    controller = controller_class.new(req, res, route_params)
    controller.invoke_action(action_name)
  end
end
