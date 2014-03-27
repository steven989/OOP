class People

  def initialize(str)
    @name = str
  end

  def greetings
    puts "Hi, my name is #{@name}"
  end

end 



class Student < People

  def learn
    puts "I get it!"
  end


end


class Instructor < People

  def teach
    puts "Everything in Ruby is an object"
  end 


end



chris=Instructor.new("Chris") # create an instructor called Chris
chris.greetings #call his greeting


christina=Student.new("Christina")  #created a student
christina.greetings #call her greeting

chris.teach
christina.learn


# christina.teach #this leads to an error resulting from the teach method not being defined in the Student class, to which Christina belongs. Christina only has two methods: learning, and geetings (inherited from being part of the People class)




