namespace :pg do
  namespace :migrations do

    desc 'Migrate the (pg) database'
    task :migrate => :environment do |task|
      puts File.exist?('db/create_schema.sql')
      puts "Done"
    end

  end
end
