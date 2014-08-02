high,low = 10, 8 
input = %{\ 
<% high.downto(low) do |n| # set high, low externally %> 
<%= n %> green bottles, hanging on the wall 
<%= n %> green bottles, hanging on the wall 
And if one green bottle should accidentally fall 
There'd be <%= n-1 %> green bottles, hanging on the wall 
<% end %> 
} 

