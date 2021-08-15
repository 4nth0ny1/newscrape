require 'nokogiri'
require 'httparty'
require 'byebug'
require 'pry'

def scraper
    # url = 'https://web.dallaschamber.org/Accounting,-Tax-Preparation,-Bookkeeping,-and-Payroll-Services' 
    url = 'https://web.dallaschamber.org/Advertising,-Public-Relations,-and-Related-Services'
    unparsed_page = HTTParty.get(url)
    parse_page = Nokogiri::HTML(unparsed_page)

    company_array = Array.new
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

        comp = {
            company_name: company.css('.ListingResults_All_ENTRYTITLELEFTBOX').text,
            address: company.css("span[@itemprop = 'street-address']").text,
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

scraper

