require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params

    parse_www_encoded_form(req.query_string) if req.query_string
    parse_www_encoded_form(req.body) if req.body
  end

  def [](key)
    key = key.to_s
    @params[key]
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  def parse_www_encoded_form(www_encoded_form)
     fused_keys_and_value = URI::decode_www_form(www_encoded_form)

     fused_keys_and_value.each do |fused_key, value|
       parsed_keys = parse_key(fused_key)
       number_of_levels = parsed_keys.length
       top_key, bottom_key = parsed_keys.first, parsed_keys.last

       if number_of_levels > 1
         @params[top_key] ||= {}
         current_hash = @params

         parsed_keys.each_with_index do |key, level|
           next_key = parsed_keys[level+1]
           break if next_key.nil?

           current_hash[key][next_key] ||= ( next_key == bottom_key ? value : {} )
           current_hash = current_hash[key]
         end
       else
         @params[top_key] = value
       end
     end
   end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
