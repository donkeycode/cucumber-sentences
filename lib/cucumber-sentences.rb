Given(/^I am on the "([^"]*)"$/) do | page_name |
    object = {
        'site_url' => $site_url
    }

    @current_page = visit_page page_name.gsub(" ","_"), :using_params => object

    step "I should be redirected on \"#{page_name}\""
end