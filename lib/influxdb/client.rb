require 'net/http'
require 'json'

module InfluxDB
  class Client
    attr_accessor :host, :port, :username, :password, :database

    # Initializes a new Influxdb client
    #
    # === Examples:
    #
    #     Influxdb.new                               # connect to localhost using root/root
    #                                                # as the credentials and doesn't connect to a db
    #
    #     Influxdb.new 'db'                          # connect to localhost using root/root
    #                                                # as the credentials and 'db' as the db name
    #
    #     Influxdb.new :username => 'username'       # override username, other defaults remain unchanged
    #
    #     Influxdb.new 'db', :username => 'username' # override username, use 'db' as the db name
    #
    # === Valid options in hash
    #
    # +:hostname+:: the hostname to connect to
    # +:port+:: the port to connect to
    # +:username+:: the username to use when executing commands
    # +:password+:: the password associated with the username
    def initialize *args
      opts = args.last.is_a?(Hash) ? args.last : {}
      @host = opts[:host] || "localhost"
      @port = opts[:port] || 8086
      @username = opts[:username] || "root"
      @password = opts[:password] || "root"
      @database = args.first
    end

    def create_database(name)
      http = Net::HTTP.new(@host, @port)
      url = "/db?u=#{@username}&p=#{@password}"
      data = JSON.generate({:name => name})
      response = http.request(Net::HTTP::Post.new(url), data)
    end

    def delete_database(name)
      http = Net::HTTP.new(@host, @port)
      url = "/db/#{name}?u=#{@username}&p=#{@password}"
      response = http.request(Net::HTTP::Delete.new(url))
    end

    def get_database_list
      http = Net::HTTP.new(@host, @port)
      url = "/dbs?u=#{@username}&p=#{@password}"
      response = http.request(Net::HTTP::Get.new(url))
    end

    def create_database_user(database, username, password)
      http = Net::HTTP.new(@host, @port)
      url = "/db/#{database}/users?u=#{@username}&p=#{@password}"
      data = JSON.generate({:username => username, :password => password})
      response = http.request(Net::HTTP::Post.new(url), data)
    end

    def write_point(name, data)
      http = Net::HTTP.new(@host, @port)
      url = "/db/#{@database}/series?u=#{@username}&p=#{@password}"
      payload = {:name => name, :points => [], :columns => []}

      point = []
      data.each_pair do |k,v|
        payload[:columns].push k.to_s
        point.push v
      end

      payload[:points].push point
      data = JSON.generate([payload])
      response = http.request(Net::HTTP::Post.new(url), data)
    end
  end
end
