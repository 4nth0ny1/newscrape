require 'nokogiri'
require 'httparty'
require 'byebug'
require 'pry'

def scraper
    url = 'https://web.dallaschamber.org/Accounting,-Tax-Preparation,-Bookkeeping,-and-Payroll-Services' 
    unparsed_page = HTTParty.get(url)
    parse_page = Nokogiri::HTML(unparsed_page)
    company_array = Array.new
    company_cards = parse_page.css('.ListingResults_All_CONTAINER')
    company_cards.each do |company|
        phone = ""
        company.css('img').each do |img|
            if img.attributes["alt"]&.value&.include?("Phone")
                phone = img.attributes['alt'].value.split(": ")[-1]
                break
            end 
        end 

        comp = {
            company_name: company.css('.ListingResults_All_ENTRYTITLELEFTBOX').text,
            address: company.css("span[@itemprop = 'street-address']").text,
            city: company.css("span[@itemprop = 'locality']").text,
            state: company.css("span[@itemprop = 'region']").text,
            zip: company.css("span[@itemprop = 'postal-code']").text,
            phone: phone
            url: company.css('.ListingResults_Level4_VISITSITE').css('a').attributes['href'].value
        }
        company_array << comp
       
    end 
    puts company_array
end 

scraper