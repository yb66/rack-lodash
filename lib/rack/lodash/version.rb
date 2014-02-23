module Rack
  class Lodash

    # The version of this library.
    VERSION = "1.2.0"

    # The version of Lo-dash it supports
    LODASH_VERSION = "2.4.1"

    # This is the release date of the Lo-dash file, it makes an easy "Last-Modified" date for setting the headers around caching.
    # @todo remember to change Last-Modified with each release! To get this, Time.parse(release_date).rfc2822
    LODASH_VERSION_DATE = "Sun, 01 Dec 2013 17:37:28 +0000"
  end
end
