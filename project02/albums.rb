#!/usr/bin/env ruby
require 'rack'
require 'erb'

def get_form_template
  %{
      <html>
      <head>
        <title>Rolling Stone's Top 100 Albums of All Time</title>
      </head>
      <body>
        <h1>Rolling Stone's Top 100 Albums of All Time</h1>
        <form action="/list" method="GET">
          <label for="sort_by">Sort by</label>
          <select name="sort_by">
            <option value="rank">Rank (default)</option>
            <option value="name">Name</option>
            <option value="year">Year</option>
          </select>
          <label for="rank">Select a Rank to Highlight</label>
          <select name="rank">"
            <% for @i in 1..100 %>
              <option value="<%= @i %>"> <%= @i %> </option>
            <% end %>
          </select>
            <input type="submit" value="Display List">
      </body>
      </html>
    }
end

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

    File.open("form.html", "w") do |f|
      f.write(ERB.new(get_form_template).result(binding))
    end

  	File.open("form.html", "rb") { |form| response.write(form.read)}
  	response.finish								            # converts object into rack expected response
  end

  def render_list(request)						        # handles the list page render
  	response = Rack::Response.new(request.path)

    File.open("list.html", "w") do |f|
      f.write(ERB.new(get_list_template).result(binding))
    end
    
    # case 
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