
## This code still doesn't have all guardrails yet against erroneous user entries, but I think it's good enought for now.
## Some examples of additional guardrails to add:
##  1) When users try to access a rover that doesn't exist yet
##  2) When users enter negative terrain size

require "etc"

class Terrain

  def initialize(size)

    size_array = size.split(" ")


    $size_x = size_array[0].to_i;
    $size_y = size_array[1].to_i;

  end

end


class Rover

  #these readers are needed when the user want to view all the instances of rovers (specified below in self.summary method)
  attr_reader :position_x 
  attr_reader :position_y
  attr_reader :direction_num

  @@initial_direction = {N:0,E:1,S:2,W:3} #this is used as a dictionary to decipher the position of each direction within the following two arrays
  @@x_pattern = [0,1,0,-1] #this is an array showing the direction (or the sign of the vector) for the x-coordinates. Each element represents the x-coordinate sign of a direction, as translated by the hash above. For example, the x-coordinate sign for north is 0 (i.e. moving north has no impact on the x-coordinate; the x-coordinate sign of west is -1)
  @@y_pattern = [1,0,-1,0] #this is a similar array showing the impact of direction on the y-coordinates 
  @@roverID = 0
  @@rovernames = []


  def initialize(position,str=@@roverID.to_s)  #ID is not really used in this code; I put this in here originally but too lazy to take it out
  

    if (defined? $size_x) == nil
      puts "You must specify the size of the terrain first"

    else
      @position = position.split(" "); 
      @position_x = @position[0].to_i; 
      @position_y = @position[1].to_i; 
      @position_orientation = @position[2].upcase;  
      @name=str;
      @@rovernames << str;
      @@roverID += 1;  #after each creation of a rover, increase this ID by 1; this is not used anymore really, but kept here because it's too much hassle to delete
      @direction_num = @@initial_direction[@position_orientation.to_sym];
      @x_impact = @@x_pattern[@@initial_direction[@position_orientation.to_sym]];
      @y_impact = @@y_pattern[@@initial_direction[@position_orientation.to_sym]];

    end

  end

  def self.summary

    if @@rovernames.length == 0 
      puts "You don't have any rovers yet!"
    else 

    @@rovernames.each { |name|

      eval("puts \"#{name} - x: \#\{$#{name}.position_x} y: \#\{$#{name}.position_y} facing: \#\{(@@initial_direction.find {|key,value| value == $#{name}.direction_num%4 })[0].to_s}\"")

    }
    end

  end


  def move(directions)

    if (defined? $size_x) == nil
      puts "You must specify the size of the terrain first"
      
    else
      directions.upcase.split("").each { |dir|
        case
          when dir == "M" 
            then  @position_x += @x_impact if @position_x + @x_impact <= $size_x and @position_x + @x_impact >= 0;   #increment the x coordinate based on both the direction and the size limit of the terrain
                  @position_y += @y_impact if @position_y + @y_impact <= $size_y and @position_y + @y_impact >= 0;   #increment the y coordinate based on both the direction and the size limit of the terrain
          when dir == "L"
            then @direction_num -= 1; 
                 @x_impact = @@x_pattern[@direction_num%4]; #the modulo is used to get a value between 0 and 3 (where 0 means north, 1 means east, 2 means south and 3 means west; see the hash at the top)
                 @y_impact = @@y_pattern[@direction_num%4];
          when dir == "R"
            then @direction_num += 1;
                 @x_impact = @@x_pattern[@direction_num%4];
                 @y_impact = @@y_pattern[@direction_num%4];
          else puts "Incorrect command"
        end
      }

      puts "Your rover is now at x:"+@position_x.to_s+" y:"+@position_y.to_s+" facing:"+(@@initial_direction.find {|key,value| value == @direction_num%4 })[0].to_s


      end
    end
  end



def choose_screen

  choice = gets.chomp.to_i

  case 

    when choice == 1 
      then
        puts "Enter two integers, separated by a space to define the size of the terrain. The first number is the x-size and the second number is the y-size (e.g. 10 10)"
        size = gets.chomp
        master_terrain = Terrain.new(size)
        puts "New Terrain is now created; what would you like to do next? \nPress 1 to enter the exploration terrain size.\nPress 2 to land a rover.\nPress 3 to view all your current rovers.\nPress 4 to move a rover."
        choose_screen.call

    when choice == 2
       then 

        if (defined? $size_x) == nil
          puts "You don't have a terrain defined yet! Let's try this again.\nPress 1 to enter the exploration terrain size.\nPress 2 to land a rover.\nPress 3 to view all your current rovers.\nPress 4 to move a rover."

        else

          loopvar = false #I want to use a loop here that asks the user to repeatedly enter the direction until the format is correct 
          puts "What would you like to call your rover? (Do not use space in the name.)"
          name = gets.chomp.gsub(/\s+/,"_")

          until loopvar == true do

          puts "What is the landing position of the rover? (e.g. X Y Orientation)"
          position = gets.chomp

            if position =~ /^[0-9]+\s+[0-9]+\s+[NESWnesw]/ and position.split(" ")[0].to_i <= $size_x and position.split(" ")[1].to_i <= $size_y and position.split(" ")[0].to_i >= 0 and position.split(" ")[1].to_i >= 0#this is to make sure that the input is in the format of 1 1 E
              loopvar = true
            else 
              if position.split(" ")[0].to_i > $size_x or position.split(" ")[1].to_i > $size_y or position.split(" ")[0].to_i < 0 or position.split(" ")[1].to_i < 0
                puts "The landing location is out of bound. Your rover will crash."
              else 
                puts "The position format doesn't look quite right...try again" 
              end
            end

          end

          eval("$#{name}=Rover.new(position,name)")
          puts "#{name} has now been landed; what would you like to do next? \nPress 1 to enter the exploration terrain size.\nPress 2 to land a rover.\nPress 3 to view all your current rovers.\nPress 4 to move a rover."        
        end

          choose_screen.call


    when choice == 3 
      then Rover.summary
      puts "What would you like to do next? \nPress 1 to enter the exploration terrain size.\nPress 2 to land a rover.\nPress 3 to view all your current rovers.\nPress 4 to move a rover."        
      choose_screen.call

    when choice == 4 
      then 
        puts "Which rover would you like to move?"
        ro= gets.chomp.gsub(/\s+/,"_")
        puts "Enter the direction for #{ro} using L R and M"
        direction = gets.chomp.gsub(/\s+/,"_")
        eval("$#{ro}.move(direction)")
        puts "What would you like to do next? \nPress 1 to enter the exploration terrain size.\nPress 2 to land a rover.\nPress 3 to view all your current rovers.\nPress 4 to move a rover."        
        choose_screen.call

    else puts "That is not a valid choice. Please choose again." ; choose_screen.call
    
  end

end



puts "Welcome to Mars #{Etc::getlogin}!\nPress 1 to enter the exploration terrain size.\nPress 2 to land a rover.\nPress 3 to view all your current rovers.\nPress 4 to move a rover."

choose_screen.call






