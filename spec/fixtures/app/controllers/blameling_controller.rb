require (File.expand_path('../blog_posts_controller', __FILE__))

module RailsApp
  class BlamelingController < BlogPostsController
    include Changeling::Blameling
  end
end
