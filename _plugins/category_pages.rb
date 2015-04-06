#
# Adapted from https://github.com/runemadsen/runemadsen-2013 
module Jekyll

  class CategoryPages < Generator
  
    safe true

    def generate(site)
      site.pages.dup.each do |page|
        if CategoryPager.pagination_enabled?(site.config, page)
          paginate(site, page) 
        end
      end
    end

    def paginate(site, page)
    
      # sort categories by descending date of publish
      #
      category = page.data['category']
      category_posts = site.categories[category].sort_by { |p| -p.date.to_f }

      # calculate total number of pages
      pages = CategoryPager.calculate_pages(category_posts, site.config['num_of_posts_to_paginate'].to_i)

      # iterate over the total number of pages and create a physical page for each
      (1..pages).each do |num_page|
      
        # the CategoryPager handles the paging and category data
        pager = CategoryPager.new(site, num_page, category_posts, category, pages)

        if num_page > 1
          newpage = Page.new(site, site.source, page.dir, page.name)
          newpage.pager = pager
          newpage.dir = File.join("/#{category}/page#{num_page}")
          site.pages << newpage
        else
          page.pager = pager
        end

      end
    end
  end
  
  class CategoryPager < Jekyll::Paginate::Pager

    attr_reader :category

    def self.pagination_enabled?(config, page)
      page.name == 'index.html' && page.data['pagination_enabled'] && !config['num_of_posts_to_paginate'].nil?
    end

    # Returns the pagination path as a string
    def paginate_path(site, num_page, category)
      return nil if num_page.nil?
      return "/#{category}" if num_page <= 1
      format = "/#{category}/page#{num_page}" 
    end
    
    # same as the base class, but includes the category value
    def initialize(site, page, all_posts, category, num_pages = nil)
      @category = category
      @page = page
      @per_page = site.config['num_of_posts_to_paginate'].to_i
      @total_pages = num_pages || Pager.calculate_pages(all_posts, @per_page)

      if @page > @total_pages
        raise RuntimeError, "page number can't be greater than total pages: #{@page} > #{@total_pages}"
      end

      init = (@page - 1) * @per_page
      offset = (init + @per_page - 1) >= all_posts.size ? all_posts.size : (init + @per_page - 1)

      @total_posts = all_posts.size
      @posts = all_posts[init..offset]
      @previous_page = @page != 1 ? @page - 1 : nil

      @previous_page_path = paginate_path(site, @previous_page, category)
      @next_page = @page != @total_pages ? @page + 1 : nil
      @next_page_path = paginate_path(site, @next_page, category)
    end
  end

  class Jekyll::Post 
    # Allow navigation to next or previous post within the same category

    def next_in_category
      return self.next if self.categories.length != 1
      category_posts = self.site.categories[self.categories[0]]
      pos = category_posts.index {|post| post.equal?(self)}
      if  pos && pos < category_posts.length - 1
           category_posts[pos + 1]
      else 
           nil
      end
    end

    def previous_in_category
      return self.previous if self.categories.length != 1
      category_posts = self.site.categories[self.categories[0]]
      pos = category_posts.index {|post| post.equal?(self)}
      if  pos && pos > 0 
           category_posts[pos - 1]
      else 
           nil
      end
    end
  end
end
