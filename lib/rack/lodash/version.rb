module Rack
  class Lodash

    # The version of this library.
    VERSION = "1.1.0"

    # The version of Lo-dash it supports
    LODASH_VERSION = "2.2.1"

    # This is the release date of the Lo-dash file, it makes an easy "Last-Modified" date for setting the headers around caching.
    # @todo remember to change Last-Modified with each release! To get this, DateTime.parse(release_date).rfc2822
    LODASH_VERSION_DATE = "Thu, 3 Oct 2013 09:42:50 +0000"
  end
end
