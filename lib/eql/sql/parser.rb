
require "rubygems"
require "parslet"

module Eql
  module Sql
    class Parser < Parslet::Parser
      rule(:integer)    { match('[0-9]').repeat(1) }
      rule(:float)      { integer.repeat >> str('.') >> integer.maybe }
      #rule(:numeric)    { integer | float | (str('-') >> numeric) }

      rule(:space)      { match('\s').repeat(1) }
      rule(:space?)     { space.maybe }
      rule(:comma)      { str(',') >> space? }
      rule(:lparen)     { str('(') >> space? }
      rule(:rparen)     { str(')') >> space? }

      # logical operators
      rule(:eq)         { str('=') }
      rule(:neq)        { str('!=') | str('<>') }
      rule(:gt)         { str('>') }
      rule(:lt)         { str('<') }
      rule(:geq)        { str('>=') }
      rule(:leq)        { str('<=') }
      rule(:btw)        { str('between') }
      #rule(:like)       { str('like') >> space? }
      rule(:binop)      { eq | neq | gt | lt | geq | leq | btw}

      rule(:string)     {
        str('"') >> 
        (
         str('\\') >> any |
         str('"').absent? >> any
         ).repeat >> 
        str('"')
      }

      rule(:const)      {
        integer | float | string
      }
      rule(:term)       { const | item }

      rule(:bool_and)   { str('and') }
      rule(:bool_or)    { str('or') }


      rule(:identifier) { match('[a-zA-Z0-9_]').repeat }


      rule(:function)   {
        identifier.as(:function) >> space? >>
        lparen >> arglist.as(:arguments) >> rparen
      }

      rule(:ref) { identifier.as(:lf) >> str("\.") >> identifier.as(:rf) }

      rule(:item)       { ref | function | identifier }
      
      rule(:as)         { str("as") >> space >> identifier.as(:as) >> space? }

      rule(:arglist)    {
        item.as(:item) >> space? >> as.maybe >> (comma >> item.as(:item) >> space? >> as.maybe).repeat
      }
      
      rule(:namelist)   {
        (identifier|ref).as(:name) >> space? >> as.maybe >> (comma >> (identifier|ref).as(:name) >> space? >> as.maybe ).repeat
      }

      rule(:single_cond){
        term.as(:lhs) >> space? >> binop.as(:op) >> space? >> term.as(:rhs)
      }

      rule(:condition)  {
        single_cond.as(:lhs) >> space? >>
        ((bool_and.as(:op) | bool_or.as(:op)) >>
         space? >>
         condition.as(:rhs)).maybe
      }

      rule(:select_s)   {
        str('select').as(:op) >> space? >> (arglist | str('*')).as(:select)
      }

      rule(:from_s)     {
        str('from') >> space? >> namelist.as(:from)
      }

      rule(:where_s)    {
        str('where') >> space? >> condition.as(:where)
      }
      
      rule(:join_s) {
        (str('join') >> space? >> namelist.as(:with) >> space? >>(str('on') >> space? >> condition.as(:on)).maybe).as(:join)
      }

      rule(:group_s)    {
        str('group') >> space? >> str('by') >> space? >> item.as(:group_by)
      }

      rule(:select)     {
        select_s >> space? >> from_s >> space? >>
        (where_s.maybe >> space? >> join_s.maybe >> group_s.maybe | group_s).maybe
      }

      ## limit 10 desc by 'col'

      rule(:expression) { select } #| insert | create }
      root :expression
    end
  end
end
