require 'json'
require 'net/http'
require 'uri'
require 'base64'
Puppet::Type.type(:consul_kv).provide(
  :default,
) do

  def connect(url)
    @uri ||= URI(url)
    @http ||= Net::HTTP.new(@uri.host, @uri.port)
  end

  ##
  # Fetch the value for provided key and return its decoded value (Values of
  # consul keys are base64 encoded).
  ##
  def getKey(url,key)
    if ! @value
      connect(url)
      path=@uri.request_uri + '/'  + key
      req = Net::HTTP::Get.new(path)
      res = @http.request(req)
      if res.code == '200'
        data = JSON.parse(res.body)
        @value = Base64.decode64(data[0]['Value'])
      elsif res.code == '404'
        @value = ''
      else
        raise(Puppet::Error,"Uri: #{@uri.to_s}/#{key} reutrned invalid return code #{res.code}")
      end
    end
    return @value
  end

  def putKey(url,key,value)
    connect(url)
    path = @uri.request_uri + '/' + key
    req = Net::HTTP::Put.new(path)
    req.body = value
    res = @http.request(req)
    if res.code != '200'
      raise(Puppet::Error,"Uri: #{@uri.to_s}/#{key} reutrned invalid return code #{res.code}")
    end
  end

  def delKey(url,key)
    connect(url)
    path = @uri.request_uri + '/' + key
    req = Net::HTTP::Delete.new(path)
    res = @http.request(req)
    if res.code != '200'
      raise(Puppet::Error,"Uri: #{@uri.to_s}/#{key} reutrned invalid return code #{res.code}")
    end
  end

  def exists?
    !getKey(resource[:url],resource[:name]).empty?
  end

  def create
    putKey(resource[:url],resource[:name],resource[:value])
  end

  def destroy
    delKey(resource[:url],resource[:name])
  end

  def value
    getKey(resource[:url],resource[:name])
  end

  def value=(value)
    putKey(resource[:url],resource[:name],resource[:value])
  end
end
