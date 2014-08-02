File.open("foo3","r") { |f| puts f.readline.chomp! until f.eof }
trap("CLD") { pid=Process.wait; puts "child: #{pid}, status: #{$?}" }

#html snippet using <button>
<form id="chooser" action="chooser.php" method="post">
  <fieldset>
   <legend>Please choose a plan from the following</legend>
   <ul>
    <li><button type="submit" name="plan" value="basic">
     <h3>Basic Plan</h3>
     <p>
      You get 20<abbr title="gigabytes">GB</abbr> of
      storage and a single domain name for
      <strong>$2.99/<abbr title="month">mo</abbr></strong>
     </p>
    </button></li>
    <li><button type="submit" name="plan" value="pro">
     <h3>Pro Plan</h3>
     <p>
      You get 100<abbr title="gigabytes">GB</abbr> of
      storage and a single domain name for
      <strong>$12.99/<abbr title="month">mo</abbr></strong>
     </p>
    </button></li>
    <li><button type="submit" name="plan" value="guru">
     <h3>Guru Plan</h3>
     <p>
      You get 500<abbr title="gigabytes">GB</abbr> of
      storage and unlimited domain names for
      <strong>$22.99/<abbr title="month">mo</abbr></strong>
     </p>
    </button></li>
   </ul>
  </fieldset>
</form>
