class LoanerPoolController < ApplicationController



  def index
    puts "--------------------In  Index------------------------------------------"
    @allUsers = User.all
    @preAllItems = Item.all
    @allItems = []
    puts "# of items = #{@preAllItems.size}"

    # Adds a new instance variable to the object. Variable is the item name with spaces removed
    for  item in @preAllItems
      def item.shortName
        @shortName = self.name.gsub(/\s+/, "")
        @shortName
      end
      @allItems.push(item)
     end
     # Sorts  items
 @allItems = @allItems.sort_by {|item| [item.amountOut, -item.amountAvalible]}

  end
     
# Allows multiple methods on the same page
  def methodSelector
    if params[:commit] == "Add New Item"
      addNewItem(params)
    else
      updateItems(params)
      return
    end
  end



      def updateItems(params) 
        
        puts "--------------------In  update Items------------------------------------------"

        numberofItems = 0
        amountLimit = 0
        remainingStudents = []
        
        # Uses  item name to find item
        itemName =  params[:name]
        row = Item.find_by(name: itemName )
       
        
        #Checks inventory
        amountAvalible = row.amountAvalible
        amountOut = row.amountOut
        
        #Checks to see how many items are being checked out or returned
        if  (params[:amountToCheckOut] =~ /(\+)/i)
           numberofItems = -1*params[:amountToCheckOut][1..-1].to_i
           amountLimit = amountOut 
         else 
           numberofItems = params[:amountToCheckOut].to_i
           amountLimit = amountAvalible
         end
         # Find student by ID
         studentRow = User.find_by(userID: params[:studentId])
       
         #Store all the sudents who currently have this item.
         remainingStudents = row.studentArray
         
         #Store all the items that this student currently has.
         if studentRow
             remainingItems =  studentRow.productArray
         else
             remainingItems = []
          end
         
        #Checks items in an out of inventory
        respond_to do |format|
              # If there exists this many items to check out or return
              if   numberofItems.abs <=  amountLimit
                    # If updating the item number is successful
                    if row.update(amountAvalible: amountAvalible - numberofItems ) && row.update(amountOut: amountOut + numberofItems) 
                           puts "Success in updating item!"
                            #If student has some of this item out already
                           if   row.studentArray.detect {|f| f["userID"] == params[:studentId]}
                                    #Update student object with the correct value for the item or the removal of an item
                                     counter = 0
                                      #Update this item so that the item object knows which students  have how many of it after this transaction
                                     remainingStudents.each do |student|
                                              if  student["userID"] == params[:studentId]
                                                     student["numberOfItems"] = student["numberOfItems"] + numberofItems
                                                     #If student has no more of this item checked out remove student from array
                                                     if student["numberOfItems"] == 0
                                                       remainingStudents.delete_at(counter)
                                                     end
                                              end  
                                              counter = counter + 1  
                                     end
                                     #Update this student so that the student object knows how many of each item it has after this transaction
                                     counter = 0
                                     remainingItems.each do |item|
                                              if  item["itemName"] == itemName
                                                    #Update count for item
                                                     item["numberOfItems"] = item["numberOfItems"] + numberofItems
                                                     if item["numberOfItems"] == 0
                                                       # Remove item from the student if the student just returned all of this item
                                                       remainingItems.delete_at(counter)
                                                     end
                                              end  
                                              counter = counter + 1  
                                     end

                                      puts "Updating Student and Item----------------------------------------------------------------------------------"
                                     if  studentRow.update(productArray: remainingItems) && row.update(studentArray: remainingStudents)
                                                  puts "Success in updating User and Item!"
                                                  format.html {redirect_to loaner_pool_url}
                                     else
                                                 puts "Fail in updating updating User and Item!"
                                                 format.html {redirect_to "/studenterror"}
                                     end
                         
                                  
                                  
                           else
                                  # If trying to add back items from a student that has none of these items checked out, fail
                                  if numberofItems < 0
                                     format.html {redirect_to "/studenterror"}
                                  else
                           
                                        itemToAdd = {"itemName" => row.name, "numberOfItems" => numberofItems }
                                        newUser = {"userID" => params[:studentId], "numberOfItems" => numberofItems }
                                        
                                        # If a student has not been previously added in the system create a new student
                                        if !studentRow
                                              
                                                    map = {"userID" => params[:studentId], "productArray" => [itemToAdd]  }
                                                    
                                                    newUserRow = User.new(map)
                                                    
                                                    if  newUserRow.save && row.update(studentArray: remainingStudents.push(newUser))
                                                        puts "Success in creating New User!"
                                                        format.html {redirect_to loaner_pool_url}
                                                    else
                                                        puts "Failure in creating New User!"
                                                        format.html {redirect_to "/error"}
                                                    end
                                         else  # use existing student by updating information and adding item to user and user to item
                                    
                                                    if  studentRow.update(productArray: remainingItems.push(itemToAdd)) && row.update(studentArray: remainingStudents.push(newUser))
                                                        puts "Success in updating User and Item!"
                                                        format.html {redirect_to loaner_pool_url}
                                                    else
                                                       puts "Fail in  updating User and Item!"
                                                        format.html {redirect_to "/error"}
                                                    end

                                         end
                                   end
                           end
                   else
                        format.html {redirect_to "/error"}
                   end
          else 
                  format.html {redirect_to "/error"}
          end
      end
  end
  
 
  def addNewItem(params)
        puts "--------------------In Add New Item------------------------------------------"
     
        name = params[:name]
        description = params[:description]
        website = params[:website]
        numberofItems = params[:number].to_i
        
        map = {"name" => name, "description" => description, "amountOut" => 0, "amountAvalible" => numberofItems, "image" => website  }
        newRow = Item.new(map)
        
        respond_to do |format|
          if newRow.save
            puts "Success at adding a new item!"
            format.html {redirect_to loaner_pool_url}
          else
            format.html {redirect_to "/error"}
          end
  end
  
end

end

