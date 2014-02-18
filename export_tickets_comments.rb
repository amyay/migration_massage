#!/usr/bin/env ruby

require 'csv'
require './case.rb'
require './user.rb'
require './message.rb'
require './string_extension.rb'

csv_filenames = ARGV
# Check if last argument is a number
if csv_filenames.last.to_i.to_s==csv_filenames.last
  max = csv_filenames.pop.to_i # per file max
end

outfile = File.open('./output/Ticket Comments.csv', "wb")
outfile << (["Ticket #", "Ticket Comment #", "Comment", "Creation Date [yyyy-MM-dd HH:mm:ss z]", "Author [id]", "Public"].join(', '))
outfile << "\n"

User.load_storage

csv_filenames.each do |csv_filename|
  puts "Processing #{csv_filename}"
  count = 0 # max is per file
  # CSV.foreach(csv_filename, :headers=>true, :header_converters=>:symbol) do |row|
    # message = Message.new row[:case_id], row[:message_id], row[:message], row[:creation_date], row[:author], row[:public]

  CSV.foreach(csv_filename, :headers=>true) do |row|
    message = Message.new count+8001, row["Ticket #"], row["Public"], row["Creation Date [EN]"], row["Case Comments"]
    message.save

    # puts message.inspect

    # only work on tickets where comment isn't empty
    next if row["Case Comments"].nil? || row["Case Comments"].empty?

    # # check to see if author is 'customer' or 'null'
    # if (row[:author].downcase == "customer")
    #   author = User.default_user
    # elsif (row[:author].downcase == "null")
    #   author = User.default_agent
    # else
    #   author = User.find_or_create_by_key row[:author]
    # end

    # grab author ID
    # puts message.inspect

    # if User.find_by_key(row["Author"].downcase).nil?
    #   # returns nil means user doens't exist
    #   author = User.find_or_create_by_key row["ACT_OWNER"].downcase
    #   author.name = row["ACT_OWNER"].downcase
    #   author.email = "unknown_author_" + row["ACT_OWNER"].downcase + "@migrationformedidata.com"
    # else
    #   # returns something so user already exist
    #   author = User.find_or_create_by_key row["ACT_OWNER"].downcase
    # end

    # limelight
    # check to see if author is defined
    # if row["Author"].nil? || row["Author"].empty?
    #   # author is nil
    #   author = User.default_commenter
    # else
    #   # author is defined! look for it
    #   author = User.find_by_name row["Author"]
    #   if author.nil?
    #     # authur doesn't currently exist in database
    #     # add to database with a dummy email
    #     fakeEmail = row["Author"].gsub ' ', '.'
    #     fakeEmail = fakeEmail.gsub ':', '.'
    #     fakeEmail = fakeEmail + "@legacylimelightuser.com"
    #     author = User.new fakeEmail
    #     author.name = row["Author"]
    #     author.act_as_agent "General"
    #     author.save
    #   end
    # end

    # limelight new
    # use legacy agent whenever the author is an agent
    # first off: check to see if message is public or private
    # since only agent can make private comments
    if !message.public?
      author = User.legacy_agent
    else
      # message is public. go on to proceed with checks
      if row["Author"].nil? || row["Author"].empty?
        # author is nil
        author = User.legacy_agent
      else
        # author is defined! look for it
        author = User.find_by_name row["Author"]
        if author.nil?
          # authur doesn't currently exist in database
          # add as end user to database with a dummy email
          fakeEmail = row["Author"].gsub ' ', '.'
          fakeEmail = fakeEmail.gsub ':', '.'
          fakeEmail = fakeEmail + "@legacylimelightuser.com"
          author = User.new fakeEmail
          author.name = row["Author"]
          author.save
        else
          # author already exist in database
          # check to see if author is agent or end user
          # if author is an agent, then use legacy agent instead
          # otherwise, leave it as end user
          if author.type == 'agent'
            author = User.legacy_agent
          end
        end
      end
    end

    # if !row["Case Comments"].nil? || !row["Case Comments"].empty?
      # Write to output csv
      quoted = Array.new
      # [message.case_id, message.id, message.body, message.created_at, author.id, message.formatted_public].each do |element|
      # [message.case_id, message.id, message.body, message.created_at, author.id, 'true'].each do |element|

      [message.case_id, message.id, message.body, message.created_at, author.id, message.is_public].each do |element|
        quoted << element.to_s.quote
      end
      outfile << quoted.join(',')
      outfile << "\n"
    # end


    count += 1
    next if max.nil?
    break if count >= max
  end
end

User.dump_storage
outfile.close

