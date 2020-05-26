require 'erb'

module Puppet::Parser::Functions

  newfunction(:encode_iss, :type => :rvalue, :doc => "This function encode the OIDC ISS field") do | args |

    result = Hash.new
    result["url"] = ERB::Util.url_encode(args[0])

    tmps = args[0]
    if tmps.start_with?("https://")
      tmps = tmps[8..-1]
    end

    if tmps.start_with?("http://")
      tmps = tmps[7..-1]
    end

    if tmps.end_with?("/")
      tmps = tmps[0..-2]
    end

    result["dir"] = ERB::Util.url_encode(tmps)

    return result

  end

end

