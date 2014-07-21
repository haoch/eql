# require 'eql/selector'

module Eql
    class Select
    def initialize tree
      @select = build_columns tree[:select]
      @from   = From.new tree[:from]
      @where  = Where.new tree[:where]
      if tree[:group_by] then
        @group_by = Group.new tree[:group_by] 
      end
      @agg = false
    end

    def build_columns items
      reqs = []
      if items.class == Array then
        items.each do |i|
          reqs << maybe_column(i[:item])
        end
      elsif items.class == Hash then
        reqs << maybe_column(items[:item])
      elsif items.to_s == "*" then
        reqs = :all
      end
      reqs
    end

    def maybe_column item
      if item.class == Hash then
        if item[:function] then
          Function.new item
        else
          # raise item
        Column.new item
        end
      else
        Column.new item
      end
    end

    def bucket
      @from.bucket
    end

    def mapper
      where = @where.to_js

      ## don't do 'select * from table group by col'
      if @select == :all then
        ERB.new(GetAllMapper).result(binding)

      elsif @group_by and @group_by.col then
        select = []
        col = @group_by.col
        @select.each do |c| select << c.to_map_js end
        ERB.new(GroupByMapperTemplate).result(binding)

      else
        select = []
        @select.each do |c| select << c.to_map_js end
        ERB.new(MapperTemplate).result(binding)

      end
    end

    def reducer
      if @select == :all then
        return nil
      end
      if @group_by and @group_by.col then
        col = @group_by.col
        return ERB.new(GroupByReducerTemplate).result(binding)
      end

      @select.each do |c|
        if c.is_agg? then
          agg_init, agg_fun = c.to_reduce_js
          return ERB.new(ReducerTemplate).result(binding)
        end
      end
      return nil
    end
  end

  def any(arr, fun)
    arr.each do |e|
      if fun(e) then
        return true
      end
    end
    return false
  end

end
