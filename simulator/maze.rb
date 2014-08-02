def solve( start )
  # been this way? then no more exits to find
  return Array::empty if start.breadcrumb_here?

  start.drop_breadcrumb # remember that we've been here

  # look, pass combines the results for us:
  other_exits = start.neighbors.pass do |direction|
    solve( direction )
  end

  if start.exit_here? # is there an exit here also?
    # include this node among the exits
    other_exits + Array::wrap( start )
  else
    other_exits
  end
end
