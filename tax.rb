
## This code also needs additional ways to catch unacceptable user entries

## Create a class of Array objects that contain all the line items


class Receipt

  @@exempt_items = []

  def initialize(items)

    @all_items = items

  end

  def self.view_exempt

    puts "These are the exempt items"
    puts @@exempt_items

  end

  def self.exempt(item)

    item.split(",").each {|x| @@exempt_items << x}

  end

  def tabulate

    @taxes = 0.00
    @cost = 0.00

    @all_items.each { |content|

      content_clean = content[0..(content.index(" at")-1)]
      quantity = content.scan(/^[1-9][0-9]*/)[0]  
      amount = content.scan(/[0-9]+\.[0-9]{2}/)[-1]  #the scan can return multiple items; this will only pick the last item
      import_flag = content.scan(/import/i).length == 0 ? 0 : 1
      
      exempt_flag = @@exempt_items.inject(0) {|sum,item| 
        
        if content.downcase.scan(item.downcase).length != 0 
          sum+=1 
        else sum+=0 
        end

      }

      exempt_flag = 1 if exempt_flag > 0

      @cost += quantity.to_i * amount.to_f


      @taxes += (((quantity.to_i * amount.to_f) * ((1-exempt_flag.to_i)*0.1) + (quantity.to_i * amount.to_f) * (import_flag.to_i * 0.05))*20.00).round/20.00

      puts "#{content_clean}: #{(@cost+@taxes).round(2)}"
      puts ""

    }

    puts "Sales Taxes: #{@taxes.round(2)}"
    puts ""
    puts "Total: #{(@cost+@taxes).round(2)}"


  end

end


## User interface

$items = []

def input_screen

  puts "Enter your line items now. Follow this format: 1 apple at 0.99 \nType \"Exemption\" to enter exempt items.\nType \"View Exemption\" to view exempted items.\nType \"View Items\" to see the items in your list. \nType \"Clear All\" to remove all items in your list.\nType \"Complete\" to check out and find the total amount. "
  input = gets.chomp

    case 
      when input == "View Exemption"
      then
        Receipt.view_exempt
        input_screen

      when input == "Exemption"
      then
        puts "Type in a list of exempt items, separated by a comma and NO space"
        exmt = gets.chomp
        Receipt.exempt(exmt)

        input_screen
      
      when input == "Complete" 
      then 
        a = Receipt.new($items)
        a.tabulate

        input_screen

      when input == "View Items"
      then 
        puts $items.length == 0 ? "There is nothing on your item list!" :  $items

        input_screen

      when input == "Clear All"
      then  
        $items = []
        puts "The item list has now been cleared"
        input_screen
    else 
      $items << input
      input_screen
    end

end

input_screen
