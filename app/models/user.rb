class User < ActiveRecord::Base
   serialize :productArray, Array
end
