module RailsApp
  class BlogPostsController < ApplicationController
    def create
      @object = BlogPost.new(models[BlogPost][:options])
      @object.save!

      models[BlogPost][:changes].each do |field, values|
        values.reverse.each do |value|
          @object.send("#{field}=", value)
          @object.save!
        end
      end
    end
  end
end
