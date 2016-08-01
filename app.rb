require 'rubygems'; require 'bundler'; Bundler.require

require 'byebug'

get '/hi' do
  "Hello World!"
end

get '/random_number' do
  random_number = rand(1000)
  respond_to do |f|
    f.txt{ "Your random number: #{random_number}"  }
    f.json{ JSON.generate({:random_number => random_number}) }
    f.html{ erb :random_number, :locals => {:random_number => random_number} }
  end
end

get '/bad.html' do
  content_type 'text/html'

  '{"bad":"html", "not really html!": true}'
end

get '/swapped_responses' do
  respond_to do |f|
    f.txt{ send_file "1.jpg"  }
    f.html{ '{"json": true}' }
    f.json{ "<html><body><h1>Hello World!</h1></body></html>" }
  end
end

put "/flexible_form_submit" do
  if request.media_type == "application/json"
    data = JSON.parse(request.body.read.to_s)
  elsif request.form_data?
    data = params
  elsif request.media_type == "cannon/custom_format"
    data = {}
    request.body.read.to_s.split("\n").each do |line|
      line_data = line.split(":")
      data[line_data[0].strip] = line_data[1].strip
    end
  else
    halt 400, "unsupported form type"
  end

  timestamp = Time.new

  erb :submitted_data, :locals => {:data => data, :timestamp => timestamp}, :format => "html"
end

post '/image' do
  request_params = JSON.parse(request.body.read.to_s)

  case request_params["image_name"]
  when "1"
    if(request_params["download"] == true)
      attachment('1.jpg')
    end

    send_file "1.jpg"
  when "2"
    if(request_params["download"] == true)
      attachment('2.jpg')
    end
    send_file "2.jpg"
  when "smile"
    png = generate_smile

    content_type 'image/png'

    if(request_params["download"] == true)
      attachment('smile.png')
    end

    png.to_blob
  else
    halt 404
  end
end

def generate_smile
  png = ChunkyPNG::Image.new(50, 50, ChunkyPNG::Color::TRANSPARENT)

  cells = 50

  cells.times do |n|
    if n % 2 == 0
      cells.times do |x|
        if x % 2 != 0
          png[x,n] = ChunkyPNG::Color.rgba(10, 20, 30, 128)
        end
      end
    end
  end

  color = ChunkyPNG::Color.from_hex("#0066ff")
  png.circle(15, 10, 5, color, color)
  png.circle(35, 10, 5, color, color)
  png.circle(25, 20, 3, color, color)

  png.line(5, 25, 25, 40, color, color)
  png.line(25, 40, 45, 25, color, color)
  png
end