class StaticPagesController < ApplicationController
  
  def home
    if signed_in?
      @micropost = current_user.microposts.build 
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
  
  def maps
    render layout: false
  end
  
  def test
    File.open('app/views/static_pages/test.txt', 'a') do |f|
      if params[:lat0] 
        36.times do |i|
          @lat = "lat" + i.to_s
          @lng = "lng" + i.to_s
          @ele = "ele" + i.to_s
        	f.puts "" + params[@lat] + " " + params[@lng] + " " + params[@ele]
        end
      else
        f.puts "fuck me"
      end
    end
    respond_to do |format|
      # respond_to refers to the action - create or destroy
      # and Rails automatically translates this into a .erb file
      # so format.js here will (probably) call test.js.erb
      format.js
    end
  end
  
  def record
    file_string = 'app/views/static_pages/' + params[:file]
    File.open(file_string, 'a') do |f|
    
      params[:length].to_i.times do |i|
        @lat = "lat" + i.to_s
        @lng = "lng" + i.to_s
        @ele = "ele" + i.to_s
        @res = "res" + i.to_s
      	f.puts "" + params[@lat] + " " + params[@lng] + " " + params[@ele] + " " + params[@res];
      end
  
    end
    
    # previously I thought it was necessary to have some kind of render here, like this:
    # respond_to do |format|
    #   format.js
    # end
    
  end

  def sender
    file_string = 'app/views/static_pages/' + params[:file]
    send_file(file_string)
  end
  
  
end # StaticPagesController
