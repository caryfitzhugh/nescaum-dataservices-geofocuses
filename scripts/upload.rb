#!/usr/bin/env ruby
require 'inquirer'
require 'net/http'
require 'json'
require 'colorize'
require 'cgi'
require 'pp'
require 'mechanize'
require 'pry'

puts ARGV[0]
host = Ask.input "API Host"
username = Ask.input "Username"
password = Ask.input("Password", password: true)

def get_geofocus(host, uid, type)
  uri = URI.parse("#{host}/geofocuses/find?uid=#{uid}&type=#{type}")
  resp = Net::HTTP.get(uri)
  JSON.parse(resp)
end

def create_geofocus(host,cookie, data)
  uri = URI.parse("#{host}/geofocuses")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = uri.scheme == 'https'
  req = Net::HTTP::Post.new(uri.path,
        initheader = {'Content-Type' => 'application/json',
                      'Cookie' => cookie.to_s,
                      'Accept' => 'application/json'})
  if (!data['geom'])
    raise "ACK. No Geom", data
  end
  req.body = JSON.generate({'geofocus' => {
    :name => data['name'],
    :uid => data['uid'] || data['name'],
    :type => data['type'],
    :geom => JSON.generate(data['geom'])
  }})
  https.request(req)
end

cookie = ''
a = Mechanize.new
a.get("#{host}") do |page|
  login_page = a.click(page.link_with(:text => /Login/))

  mypage = login_page.form_with(:action => "/sign_in") do |f|
    f.field_with(:name => "username") do |uname_field|
      uname_field.value = username
    end
    f.field_with(:name => "password") do |pword_field|
      pword_field.value = password
    end
  end.submit

  cookie = a.cookie_jar.jar[URI.parse(host).hostname]['/']['rack.session']
  ids = []
  Dir[ARGV[0] || "**/*.geojson"].each do |geojson_file|
    data = JSON.parse(File.read(geojson_file))
    resp =  get_geofocus(host, data['uid'] || data['name'], data['type'])
    if resp['code'] == 404
      # Create
     create_result = create_geofocus(host, cookie, data)
     puts "Created #{data['name']}".green
    else
      ids.push(resp['id'])
      puts "Already exists".yellow# Update
    end
  end
      require 'pp'
      pp ids
end
#sign_in_page = Net::HTTP.get(host, '/sign_in')
#puts sign_in_page
