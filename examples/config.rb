require 'sinatra/base'
require 'haml'
require 'rack/lodash'

class App < Sinatra::Base

  enable :inline_templates
  use Rack::Lodash

  get "/" do
    output = <<STR
!!!
%body
  %ul
    %li
      %a{ href: "/jsdelivr-cdn"} jsdelivr-cdn
    %li
      %a{ href: "/cloudflare-cdn"} cloudflare-cdn
    %li
      %a{ href: "/unspecified-cdn"} unspecified-cdn
    %li
      %a{ href: "/specified-via-use"} specified-via-use
STR
    haml output
  end

  get "/jsdelivr-cdn" do
    haml :index, :layout => :jsdelivr
  end

  get "/cloudflare-cdn" do
    haml :index, :layout => :cloudflare
  end

  get "/unspecified-cdn" do
    haml :index, :layout => :unspecified
  end
end


# This is probably the one I'd use.
class App2 < Sinatra::Base

  enable :inline_templates
  use Rack::Lodash, :organisation => :jsdelivr

  get "/" do
    haml :index, :layout => :specified_via_use
  end
end

__END__

@@jsdelivr
!!!
%head
  = Rack::Lodash.cdn( env, :organisation => :jsdelivr )
%body
  = yield

@@cloudflare
!!!
%head
  = Rack::Lodash.cdn( env, :organisation => :cloudflare )
%body
  = yield

@@unspecified
!!!
%head
  = Rack::Lodash.cdn(env)
%body
  = yield

@@specified_via_use
!!!
%head
  = Rack::Lodash.cdn(env)
%body
  = yield

@@index

%pre#example
  :plain
    var stooges = [
      { 'name': 'curly',
        'quotes': ['Oh, a wise guy, eh?', 'Poifect!']
      },
      { 'name': 'moe',
        'quotes': ['Spread out!', 'You knucklehead!']
      }
    ];
  
    document.getElementById("placeholder").textContent= "&lt;p&gt;" + _.flatten(stooges, 'quotes') + "&lt;/p&gt;";
  
#placeholder
:javascript
  var stooges = [
    { 'name': 'curly',
      'quotes': ['Oh, a wise guy, eh?', 'Poifect!']
    },
    { 'name': 'moe',
      'quotes': ['Spread out!', 'You knucklehead!']
    }
  ];

  document.getElementById("placeholder").textContent= "<p>" + _.flatten(stooges, 'quotes') + "</p>";