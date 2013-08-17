require "rack/lodash/version"
require "rack/jquery/helpers"

module Rack
  class Lodash
    include Rack::JQuery::Helpers # for caching

    # Namespaced CDNs for convenience.
    module CDN

      # Script tags for the Media Temple CDN
      CLOUDFLARE = "//cdnjs.cloudflare.com/ajax/libs/lodash.js/#{LODASH_VERSION}/lodash.min.js"

      # Script tags for the jsDelivr CDN
      JSDELIVR = "//cdn.jsdelivr.net/lodash/#{LODASH_VERSION}/lodash.backbone.min.js"
    end


    # The file name to use for the fallback route.
    LODASH_FILE_NAME = "lodash-#{LODASH_VERSION}.min.js"


    # This javascript checks if the Lodash object has loaded. If not, that most likely means the CDN is unreachable, so it uses the local minified Lodash.
    FALLBACK = <<STR
<script type="text/javascript">
  if (typeof _ == 'undefined') {
    document.write(unescape("%3Cscript src='/js/#{LODASH_FILE_NAME}' type='text/javascript'%3E%3C/script%3E"))
  };
</script>
STR


    # @param [Hash] env The rack env.
    # @param [Hash] opts Extra options.
    # @options opts [Symbol] :organisation Choose which CDN to use, either :cloudflare or :jsdelivr. The default is :cloudflare. If an organisation was set via the Rack env this will override it.
    # @return [String] The HTML script tags to get the CDN.
    def self.cdn( env, opts={} )
      organisation =  opts[:organisation] ||
                        (env["rack.lodash"] && env["rack.lodash"]["organisation"]) ||
                        Rack::Lodash::DEFAULT_ORGANISATION

      script = case organisation
        when :cloudflare then CDN::CLOUDFLARE
        when :jsdelivr then CDN::JSDELIVR
        else CDN::CLOUDFLARE
      end
      "<script src='#{script}'></script>\n#{FALLBACK}"
    end


    # The default CDN to use.
    DEFAULT_ORGANISATION = :cloudflare


    # Default options hash for the middleware.
    DEFAULT_OPTIONS = {
      :http_path => "/js",
      :organisation => DEFAULT_ORGANISATION
    }


    # @param [#call] app
    # @param [Hash] options
    # @option options [String] :http_path If you wish the Lodash fallback route to be "/js/lodash-1.3.1.min.js" (or whichever version this is at) then do nothing, that's the default. If you want the path to be "/assets/javascripts/lodash-1.3.1.min.js" then pass in `:http_path => "/assets/javascripts".
    # @option options [Symbol] :organisation Choose which CDN to use, either :cloudflare or :jsdelivr. The default is :cloudflare.
    # @example
    #   # The default:
    #   use Rack::Lodash
    #
    #   # With a different route to the fallback:
    #   use Rack::Lodash, :http_path => "/assets/js"
    #
    #   # With the CDN specified via the use statement
    #   use Rack::Lodash, :organisation => :jsdelivr
    def initialize( app, options={} )
      @app, @options  = app, DEFAULT_OPTIONS.merge(options)
      @http_path_to_lodash = ::File.join @options[:http_path], LODASH_FILE_NAME
      @organisation = @options[:organisation]
    end


    # @param [Hash] env Rack request environment hash.
    def call( env )
      dup._call env
    end


    # For thread safety
    # @param (see #call)
    def _call( env )
      env.merge! "rack.lodash" => {"organisation" => @organisation}

      request = Rack::Request.new(env.dup)
      if request.path_info == @http_path_to_lodash
        response = Rack::Response.new
        # for caching
        response.headers.merge! caching_headers( LODASH_FILE_NAME, LODASH_VERSION_DATE)

        # There's no need to test if the IF_MODIFIED_SINCE against the release date because the header will only be passed if the file was previously accessed by the requester, and the file is never updated. If it is updated then it is accessed by a different path.
        if request.env['HTTP_IF_MODIFIED_SINCE']
          response.status = 304
        else
          response.status = 200
          response.write ::File.read( ::File.expand_path "../../../vendor/assets/javascript/libs/lodash/#{LODASH_VERSION}/lodash.min.js", __FILE__)
        end
        response.finish
      else
        @app.call(env)
      end
    end # call

  end
end
