module UsersHelper

# Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 42} )
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")

# would it be faster to create a hash or list of these, saving them locally, 
# to avoid going back to the gravatar website over and over?
  end

end
