def  vimsyn(text, filetype)
   synfile = Tempfile.new('synfile')
   synfile.close
   codefile = Tempfile.new('codefile')
   codefile << text
   codefile.close

   # filetype="matlab"

   expr = %Q%/usr/local/bin/vim -f -n -X -e -s -c \
       "set filetype=#{filetpe}" \
       -c "syntax on" \
       -c "set background=dark" \
       -c "let html_use_css=1" \
       -c "run syntax/2html.vim" \
       -c "wq! #{synfile.path}" -c "q" \ 
       #{codefile.path}%

   `#{expr}`
   html = IO.readlines(synfile.path).join
   body = html.match(/<body.*<\/body>/m)[0]
   css  = html.match(/<style.*<\/style>/m)[0]
   css.gsub!(/pre/,'pre.code')
   css.gsub!(/^body.*$/,'')
   body.gsub!(/^<body/,'<div')
   body.gsub!(/<\/body>/,'<div>')                                        
   body.gsub!(/<pre>/,'<pre class=code>')

   return css+body
end
