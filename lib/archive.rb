def articles_by_month
  blk = -> do
    sorted_articles.group_by do |article|
      Date::new(article[:created_at].year, article[:created_at].month)
    end
  end

  if @items.frozen?
    @article_by_month_items ||= blk.call
  else
    blk.call
  end
end

def articles_by_tag
  blk = -> do
    tags = Hash.new { |hash, key| hash[key] = [] }
    sorted_articles.each do |post|
      (post[:tags] || []).each { |tag| tags[tag] << post }
    end
    tags
  end

  if @items.frozen?
    @article_by_tag_items ||= blk.call
  else
    blk.call
  end
end

def article_years
  Range::new(sorted_articles.last[:created_at].year,
             sorted_articles.first[:created_at].year)
end
