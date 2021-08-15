require 'nokogiri'
require 'httparty'
require 'byebug'
require 'pry'

def scraper

    # get all links from the member directory /

    url_mother = 'https://web.dallaschamber.org/search'
    unparsed_page_mother = HTTParty.get(url_mother)
    parse_page_mother = Nokogiri::HTML(unparsed_page_mother)
    mother_array = Array.new 
    url_container = parse_page_mother.css('.ListingCategories_AllCategories_CATEGORY')

    url_container.each do |title|
        link = 'https://web.dallaschamber.org/' + title.css('a')[0].attributes['href'].value
        mother_array << link
    end 

    # get data from each link 

    company_array = Array.new
    mother_array.each do |url|
        unparsed_page = HTTParty.get(url)
        parse_page = Nokogiri::HTML(unparsed_page)

        company_cards = parse_page.css('.ListingResults_All_CONTAINER')

        company_cards.each do |company|
            
            phone = ""
            url = ""

            company.css('img').each do |img|
                if img.attributes["alt"]&.value&.include?("Phone")
                    phone = img.attributes['alt'].value.split(": ")[-1]
                    break
                end 
            end 

            company.css('a').each do |anchor_tag|
                if anchor_tag.children.text == "Visit Site"
                    url = anchor_tag.attributes['href']&.value
                    break
                end 
            end

            # company.css('.ListingResults_Level5_MAINLEFTBOX').traverse do |node|
            #     if node.text? && (node.parent.name == "div")
            #         unit = node.content
            #     end
            # end 
            # https://stackoverflow.com/questions/34234247/extract-text-between-nodes-with-nokogiri-in-a-ruby-script
            
            comp = {
                company_name: company.css('.ListingResults_All_ENTRYTITLELEFTBOX').text,
                address: company.css("span[@itemprop = 'street-address']").text,
                # unit: unit,
                city: company.css("span[@itemprop = 'locality']").text,
                state: company.css("span[@itemprop = 'region']").text,
                zip: company.css("span[@itemprop = 'postal-code']").text,
                phone: phone,
                url: url
            }

            company_array << comp   
        
        end  

        File.open('output.txt', 'w') do |fo|
            company_array.each do |company|

                array = company[:zip].split('')
                zipArray = Array.new
                array.each do |num|
                    if (num == " ")
                        break
                    end
                    zipArray << num
                end     
                
                fo.puts company[:company_name]
                fo.puts company[:address]
                fo.puts company[:city] + ', ' + company[:state] + ' ' + zipArray.join('')
                fo.puts company[:phone]
                fo.puts company[:url]
                fo.puts '' 

            end
        end 
    end 
end 

scraper
 
# bug not getting all of the address  suite numbers are being left off
