# encoding: UTF-8

class PagesController < ApplicationController
  
  before_filter :nav_bar_groups
  before_filter :group1_navigation_links, except: [:index]
  before_filter :group2_navigation_links, only: [:blosm_bworkshop]
  before_filter :group3_navigation_links, only: [:leadership, :news, :blog, :contact_us]
  before_filter :group4_navigation_links, only: [:customer_successes, :industries]
    
  def index
    render :layout => 'index_layout'
  end
  
  def send_email_lead # take params and pass to mailer to send email, redirect :back, :notice of some type
    SalesMailer.generate_lead_email(params).deliver
    redirect_to :back, notice: "Thank you. We will contact you soon!"
  end

  def topic_title(topic,grouptitle)
    @group_title = grouptitle
    @topic = topic
    @title = "#{topic}"
  end

  def nav_bar_groups
    @nav_bar_groups = { :group1 => [ 
                                      { :name => "Enrich Product Content",            :url => enrich_content_url},
                                      { :name => "Grow Your Business",        :url => grow_your_business_url},
                                      { :name => "Monitor Your Competition",  :url => monitor_your_competition_url},
                                      { :name => "Manage Your Brand",         :url => manage_your_brand_url},
                                      { :name => "Monitor Your Brand",        :url => monitor_your_brand_url},          
                                      { :name => "Monitor Social Media",      :url => monitor_social_media_url},          
                                      { :name => "Monitor Resellers",         :url => monitor_resellers_url}          
                                                                                                                      ],
                        :group2 => [
                                      { :name => "bWorkshop",               :url => blosm_bworkshop_url}          
                                                                                                                      ],
                                                                                       
                        :group3 => [                                                  
                                      { :name => "Leadership",                   :url => leadership_url },
                                      { :name => "News & Events",                         :url => news_url },
                                      #{ :name => "Blog",                         :url => blog_url },
                                      { :name => "Contact Us",                   :url => contact_us_url }             
                                                                                                                      ],
                        :group4 => [                                                  
                                      { :name => "Customer Successes",            :url => customer_successes_url },
                                      #{ :name => "Our Industries",                 :url => industries_url }             
                                                                                                                      ]
                      }
  end
    
  def group1_navigation_links
    @navigation_links = @nav_bar_groups[:group1]
  end
  
  def group2_navigation_links
    @navigation_links = @nav_bar_groups[:group2]
  end
  
  def group3_navigation_links
    @navigation_links = @nav_bar_groups[:group3]
  end
  
  def group4_navigation_links
    @navigation_links = @nav_bar_groups[:group4]
  end

  def build_page(group, topic, partial)
    @partial = partial    
    topic_title(topic,
                      if group == "group1";"What We Do"
                      elsif group == "group2";"What We Build"
                      elsif group == "group3";"Who We Are"
                      else;"Why Blosm"
                      end
                                                              )
    render group
  end

# Group 1
  def enrich_content
    build_page("group1", "Enrich Product Content", "enrich_content")
  end    

  def grow_your_business
    build_page("group1", "Grow Your Business", "grow_your_business")
  end  

  def monitor_your_competition
    build_page("group1", "Monitor Your Competition", "monitor_your_competition")
  end
    
  def manage_your_brand
    build_page("group1", "Manage Your Brand", "manage_your_brand")
  end  

  def monitor_your_brand
    build_page("group1", "Monitor Your Brand", "monitor_your_brand")
  end  

  def monitor_social_media
    build_page("group1", "Monitor Social Media", "monitor_social_media")
  end  

  def monitor_resellers
    build_page("group1", "Monitor Resellers", "monitor_resellers")
  end  

# Group 2
  def blosm_bworkshop
    build_page("group2", "bWorkshop", "blosm_bworkshop")
  end

# Group 3  
  def leadership
    build_page("group3", "Leadership", "leadership")
  end

def news
    @news_items = [ { :date => "September 10-12, 2012", 
                      :title => "Meet up with the Blosm team at Shop.org", 
                      :url => "http://www.shop.org/summit12",
                      :teaser => "Our team will be at shop.org to connect with customers and prospects.  Please drop us a line to schedule a meet up." },
                    { :date => "June 5-8, 2012", 
                      :title => "Visit the Blosm booth at IRCE 2012", 
                      :url => "http://irce.internetretailer.com/2012/",
                      :teaser => "Learn more about the Blosm platform and how it can help automate your data processing needs.  Win a free iPad and also have a chance in our money booth!" },
                    { :date => "March 28, 2012", 
                      :title => "Number1Direct Chooses Blosm Technology", 
                      :url => "http://bit.ly/Jwt2gp",
                      :teaser => "In order to automate and expedite content gathering for their vast product catalog, Number1Direct decided to move away from off-shore third parties in favor of Blosm." }
                    ]
    build_page("group3", "News & Events", "news")
  end
  
  def blog
    build_page("group3", "Blog", "blog")
  end

  def contact_us
    build_page("group3", "Contact Us", "contact_us")
  end

# Group 4
  def customer_successes
    build_page("group4", "Customer Successes", "customer_successes")
  end

  def industries
    build_page("group4", "Our Industries", "industries")
  end
end
