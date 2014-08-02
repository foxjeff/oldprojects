
       def activate
         puts "activating"
       end
   
       def release(product)
         puts "releasing product: #{product}"
       end
   
       def refund
         puts "refuding dollar"
       end
   
       def sales_mode
         puts "going into sales mode"
       end
   
       def operation_mode
         puts "going into operation mode"
       end
   

 vending_machine = Statemachine.build do
       state :waiting do
           event :dollar, :paid, :activate
         event :selection, :waiting
         on_entry :sales_mode
         on_exit :operation_mode
       end
     trans :paid, :selection, :waiting, :release
     trans :paid, :dollar, :paid, :refund
     context VendingMachineContext.new
   end

vm=vending_machine

vm.dollar
vm.dollar
vm.dollar

vm.selection "Peanuts"

