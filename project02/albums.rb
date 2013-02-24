#!/usr/bin/env ruby
require 'rack'
require_relative 'album'

class AlbumApp
  def call(env)
  	request = Rack::Request.new(env)			# env is hash with web app data [web status code, {"Content-Type" => "type", ["body of response"]}]
  	case request.path
  		when "/form" then render_form(request)	# when the path is for form
  		when "/list" then render_list(request)	# when the path is for list
  		else render_404							            # neither, 404
  	end
  end
  
  def render_form(request)						        # handles the form page render
  	response = Rack::Response.new
    rank_array = Array.new
    # form_template = get_template

    File.open("form_top.html", "rb") { |form| response.write(form.read) }
    (1..100).each { |i| response.write("<option value=\"#{i}\">#{i}</option>\n") }
    File.open("form_bottom.html", "rb") { |form| response.write(form.read) }
  	response.finish								            # converts object into rack expected response
  end

  def render_list(request)						        # handles the list page render
  	response = Rack::Response.new(request.path)
    response.write "Params: #{request.params}\n"
    response.write "order: #{request.params['order']}\n"
    response.write "rank: #{request.params['rank']}\n"
    File.open("list_top.html", "rb") { |template| response.write(template.read) }
    
    album_data = File.readlines("top_100_albums.txt")
    albums = album_data.each_with_index.map { |record, i| Album.new(i, record) }

    albums.each do |album|
      response.write("\t<tr>\n")
      response.write("\t\t<td>#{album.rank}</td>\n")
      response.write("\t\t<td>#{album.title}</td>\n")
      response.write("\t\t<td>#{album.year}</td>\n")
      response.write("\t</tr>\n")
    end

  	File.open("list_bottom.html", "rb") { |template| response.write(template.read) }
    response.finish
  end

  def render_404								              # handles the 404 page
  	[404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end
end

Signal.trap('INT') {
  Rack::Handler::WEBrick.shutdown
}

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080