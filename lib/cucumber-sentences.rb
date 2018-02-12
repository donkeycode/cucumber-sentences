Given(/^I am on the "([^"]*)"$/) do | page_name |
    object = {
        'site_url' => $site_url
    }

    @current_page = visit_page page_name.gsub(" ","_"), :using_params => object

    step "I should be redirected on \"#{page_name}\""
end


Given(/^I change the domain to "([^"]*)"$/) do | domain_name |
    require File.join(ENV['CUCUMBER_ROOT'],'support/helpers/domain')
    domain = Domain.get(domain_name)

    unless domain
        throw "Domain #{domain_name} not found !"
    end

    $site_url = domain
end

Given(/^I am on the "([^"]*)" of (.+) "([^"]*)"$/) do | page_name, type, identifier |
    require File.join(ENV['CUCUMBER_ROOT'], 'support/helpers/'+ type)
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
    nb_retry = 0

    begin
        expect(@current_page.get_field(field).when_visible().value).to include(Fakable.fake_if_needed(value))
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

Then(/^I should not see the button "([^"]*)"$/) do | dom_element_name |
    @current_page.get_button(dom_element_name).when_not_present()
end

Then(/^I should not see the element "([^"]*)"$/) do | dom_element_name |
    @current_page.get_element_by_name(dom_element_name).when_not_present()
end

Then(/^I should not see the field "([^"]*)"$/) do | dom_element_name |
    @current_page.get_field(dom_element_name).when_not_present()
end

Then(/^I should see a message tell me "([^"]*)"$/) do | text |
    nb_retry = 0

    begin
        expect(@current_page.text).to include(Fakable.fake_if_needed(text))
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


Given(/^I fill "([^"]*)" autocomplete with "([^"]*)"$/) do |field, value|
    @current_page.get_field(field).when_visible().value = Fakable.fake_if_needed(value)

    sleep 2

    @current_page.get_field("selected_autocomplete").when_visible().click()
end

Given(/^I can see the value "([^"]*)" selected in the select box "([^"]*)"$/) do |value, field|
    nb_retry = 0

    begin
        expect(@current_page.get_field(field).when_visible().selected_options()).to include(value)
    rescue Watir::Exception::NoValueFoundException
        if nb_retry < 30
            nb_retry = nb_retry + 1

            sleep 1
            retry
        else
            raise
        end
    end

end

Given(/^I fill "([^"]*)" datepicker with "([^"]*)"$/) do |field, value|
    nb_retry = 0
    begin
        @current_page.get_field(field).when_visible().value = Fakable.fake_if_needed(value)
    rescue Watir::Wait::TimeoutError
        # Do not add sleep more, just retry, it's already a timeout error (from when_visible method)
        if nb_retry < 5
            nb_retry = nb_retry + 1
            retry
        else
            raise
        end
    rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
        if nb_retry < 30
            nb_retry = nb_retry + 1
            sleep 1
            retry
        else
            raise
        end
    end
    js  = 'let calendars = document.getElementsByClassName("show-calendar");';
    js += 'for(let idx=0; idx < calendars.length; idx++) {';
    js += '  calendars[idx].removeAttribute("style");';
    js += '  calendars[idx].classList.remove("show-calendar");';
    js += '}';
    @browser.execute_script js
end

When(/^I click on the button "([^"]*)"$/) do | button |
    if not @current_page.get_button(button)
        throw "Button #{button} not found"
    end

    @current_page.get_button(button).when_visible().wait_until do
        not @current_page.get_button(button).disabled?
    end

    @current_page.get_button(button).click()
end

Given(/^I try visit the page "([^"]*)" of ([^"]*) "([^"]*)"$/) do | page_name, type, identifier |
    require File.join(ENV['CUCUMBER_ROOT'], 'support/helpers/'+ type )
    typeClassName = type.sub(/^(\w)/) {|s| s.capitalize}

    clazz = Object.const_get(typeClassName)
    object = clazz.get(identifier)
    object['site_url'] = $site_url

    unless object
        throw "Object #{type} with id #{identifier} not found !"
    end

    visit_page page_name.gsub(" ","_"), :using_params => object
end

Then(/^I can see "([^"]*)" in element "([^"]*)"(| exactly)$/) do | text, dom_element_name, exactly |
    nb_retry = 0

    begin
        if exactly == ' exactly'
            expect(@current_page.get_element_by_name(dom_element_name).when_visible().text).to eq(Fakable.fake_if_needed(text))
        end
        expect(@current_page.get_element_by_name(dom_element_name).when_visible().text.downcase).to include(Fakable.fake_if_needed(text).downcase)
    rescue RSpec::Expectations::ExpectationNotMetError
        if nb_retry < 30
            nb_retry = nb_retry + 1
            sleep 1
            retry
        else
            raise
        end
    rescue Watir::Wait::TimeoutError
        # Do not wait more, just retry, it's already a timeout error (from when_visible method)
        if nb_retry < 5
            nb_retry = nb_retry + 1
            sleep 1
            retry
        else
            raise
        end
    rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
        if nb_retry < 30
            nb_retry = nb_retry + 1
            sleep 1
            retry
        else
            raise
        end
    end
end

Then(/^I can see "([^"]*)" in input "([^"]*)"$/) do | value, input |
    expect(@current_page.get_field(input).when_visible().value).to include(Fakable.fake_if_needed(value))
end

Then(/^I should not see a message tell me "([^"]*)"$/) do | text |
    sleep 2

    expect(@current_page.text).not_to include(Fakable.fake_if_needed(text))
end

Then(/^I should see the (button|field|element) "([^"]*)"(| disabled)$/) do | element_type, dom_element_name, modifier |
    nb_retry = 0

    begin
        if element_type == 'button'
            if modifier == ' disabled'
                expect(@current_page.get_button(dom_element_name).when_visible.enabled?).to be false
            else
                expect(@current_page.get_button(dom_element_name).visible?).to be true
            end
        end
        if element_type == 'field'
            expect(@current_page.get_field(dom_element_name).visible?).to be true
        end
        if element_type == 'element'
            expect(@current_page.get_element_by_name(dom_element_name).visible?).to be true
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

Given(/^I fill "([^"]*)" ckeditor field with "([^"]*)"$/) do |field, value|
    nb_retry = 0
    begin
        jslist = "return Object.keys(CKEDITOR.instances);"
        puts @browser.execute_script jslist
        js = "CKEDITOR.instances." + @current_page.get_ckeditor(field)  + ".setData(\"" + value + "\");";
        @browser.execute_script js
        js = "CKEDITOR.instances." + @current_page.get_ckeditor(field)  + ".fire(\"change\");";
        @browser.execute_script js
        step "I can see \"#{value}\" in ckeditor \"#{field}\""

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

Given(/^I can see "([^"]*)" in ckeditor "([^"]*)"$/) do |value, field|
    nb_retry = 0
    begin
        js2 = "return CKEDITOR.instances." + @current_page.get_ckeditor(field);
        # js2  = "if (!CKEDITOR.instances." + @current_page.get_ckeditor(field)  + ".document) {"
        # js2 += "    return CKEDITOR.instances." + @current_page.get_ckeditor(field) + ";";
        # js2 += "}";

        puts js2

        js  = "if (!CKEDITOR.instances." + @current_page.get_ckeditor(field)  + ".document) {"
        js += "    return CKEDITOR.instances." + @current_page.get_ckeditor(field)  + ".getData();";
        js += "}";
        js += "return CKEDITOR.instances." + @current_page.get_ckeditor(field)  + ".document.getBody().getText();";

        ckEditorText = @browser.execute_script js
        expect(ckEditorText).to include(value)

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

Given(/^I refresh the page$/) do
    @browser.driver.navigate().refresh()
end

Given(/^I wait ([^"]*) seconds$/) do |value|
    sleep value.to_i
end

When(/^I scroll to "([^"]*)"$/) do |elementClass|
    @current_page.get_element_by_name(elementClass).when_visible().scroll_into_view
end

Then(/^I can not see "([^"]*)" in element "([^"]*)"$/) do | text, dom_element_name |
    nb_retry = 0
    begin
        expect(@current_page.get_element_by_name(dom_element_name).when_visible().text).not_to include(text)
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

When(/^I upload a file with the filename "([^"]*)" in element "([^"]*)"$/) do |path, dropzone|
    nb_retry = 0
    begin
        dz = @current_page.get_field(dropzone)
        dz = dz.set(File.join(ENV['CUCUMBER_ROOT'], 'support/files/' + path))
    rescue Watir::Exception::UnknownObjectException
        if nb_retry < 30
            nb_retry = nb_retry + 1

            sleep 1
            retry
        else
            raise
        end
    end
end

When(/^I hover over the element "([^"]*)"$/) do |element|

    nb_retry = 0
    begin
        @browser.driver.action.move_to(@current_page.get_element_by_name(element).wd).perform
    rescue
        if nb_retry < 30
            nb_retry = nb_retry + 1

            sleep 1
            retry
        else
            raise
        end
    end
end


Given(/^I make one pause$/) do
    sleep 5
end

Given(/^I fill "([^"]*)" contenteditable with "([^"]*)"$/) do |field, value|
    @current_page.get_field(field).when_visible().send_keys(Fakable.fake_if_needed(value))
end

Given(/^I fill "([^"]*)" js field with "([^"]*)"$/) do |field, value|
    selector = @current_page.get_js_selector(field);
    js = "document.querySelector('"+selector+"').value = '" +Fakable.fake_if_needed(value)+"'; document.querySelector('"+selector+"').dispatchEvent(new Event('change'));"
    @browser.execute_script js
end

## Mail hog
Then(/^I see the last email subject "([^"]*)"$/) do |subject|
    step 'I can see "'+subject+'" in element "last-message-subject"'
end

When(/^I open on the last email link$/) do
    @browser.execute_script "document.querySelector('.msglist-message .subject').click();";
    sleep 1
    @browser.execute_script "document.location.href= jQuery(document.querySelector('iframe').attributes.srcdoc.value).find('a').attr('href')"
end

dateCurrent = Time.new

When(/^I force scroll to "([^"]*)"$/) do |elementClass|
    selector = @current_page.get_js_selector(elementClass)
    js = "document.getElementById('"+selector+"').scrollIntoView();"
    @browser.execute_script js
end

Given(/^I fill "([^"]*)" field with date$/) do |field|
    @current_page.get_field(field).when_visible().value = dateCurrent.strftime("%Y-%m-%d")
end

Then(/^I should see field "([^"]*)" filled date$/) do |field|
    nb_retry = 0

    begin
        expect(@current_page.get_field(field).when_visible().value).to eq(dateCurrent.strftime("%Y-%m-%d"))
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

Given(/^I fill "([^"]*)" field with time$/) do |field|
    @current_page.get_field(field).when_visible().value = dateCurrent.strftime("%H:%M")
end

Then(/^I should see field "([^"]*)" filled time$/) do |field|
    nb_retry = 0

    begin
        expect(@current_page.get_field(field).when_visible().value).to eq(dateCurrent.strftime("%H:%M"))
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




class Fakable
	@@memorized_strings = {}

	def self.fake_if_needed(value)
		regexp = /@\('(.+)', '(.+)', '(.+)'\)/;
		parts = value.scan(regexp)

		if 0 == parts.length
			return value
		end

		value.gsub(regexp, Fakable.fake(parts[0][0], parts[0][1], parts[0][2]))
	end

	def self.fake(category, type, mem)

		if @@memorized_strings.has_key? mem
            return @@memorized_strings[mem];
        end

        category = category.sub(/^(\w)/) {|s| s.capitalize}

        return @@memorized_strings[mem] = eval("Faker::#{category}.#{type}")
	end
end