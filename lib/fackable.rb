
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