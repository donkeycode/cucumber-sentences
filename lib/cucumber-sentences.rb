Given(/^I am on the "([^"]*)"$/) do | page_name |
    object = {
        'site_url' => $site_url
    }

    @current_page = visit_page page_name.gsub(" ","_"), :using_params => object

    step "I should be redirected on \"#{page_name}\""
end


Given(/^I change the domain to "([^"]*)"$/) do | domain_name |
    require File.join(ENV.CUCUMBER_ROOT,'support/helpers/domain')
    domain = Domain.get(domain_name)

    unless domain
        throw "Domain #{domain_name} not found !"
    end

    $site_url = domain
end

Given(/^I am on the "([^"]*)" of (.+) "([^"]*)"$/) do | page_name, type, identifier |
    require File.join(ENV.CUCUMBER_ROOT, 'support/helpers/'+ type)
    typeClassName = type.sub(/^(\w)/) {|s| s.capitalize}

    clazz = Object.const_get(typeClassName)
    object = clazz.get(Fakable.fake_if_needed(identifier))
    object['site_url'] = $site_url

    unless object
        throw "Object #{type} with id #{identifier} not found !"
    end

    @current_page = visit_page page_name.gsub(" ","_"), :using_params => object

    step "I should be redirected on \"#{page_name}\""
end

Given(/^I fill "([^"]*)" field with "([^"]*)"$/) do |field, value|
    @current_page.get_field(field).when_visible().value = Fakable.fake_if_needed(value)
end


Then(/^I should see field "([^"]*)" filled "([^"]*)"$/) do |field, value|
    expect(@current_page.get_field(field).when_visible().value).to include(Fakable.fake_if_needed(value))
end

Given(/^I click on the select box "([^"]*)" to select "([^"]*)"$/) do |field, value|
    @current_page.get_field(field).when_visible().select(Fakable.fake_if_needed(value))
end

Given(/^I try visit the page "([^"]*)"$/) do | page_name |
    object = {
        "site_url" => $site_url
    }
    visit_page page_name.gsub(" ","_"), :using_params => object
end

Then(/^I should be redirected on "([^"]*)"$/) do | page_name |
    object = {
        'site_url' => $site_url
    }
    nb_retry = 0

    begin
        on_page page_name.gsub(" ","_"), :using_params => object do | page |
            @current_page = page

            if page.respond_to?('is_on_page')
                expect(page.is_on_page(@browser.url)).to be true
            else
                expect(@browser.url).to eq(page.page_url_value)
            end
        end
    rescue RSpec::Expectations::ExpectationNotMetError
        if nb_retry < 30
            nb_retry = nb_retry + 1

            sleep 1
            retry
        else
            raise
        end
    end
end
