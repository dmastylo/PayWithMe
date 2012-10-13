namespace :bootstrap do
  desc "Add the default payment processors"
  task :default_processors => :environment do
    Processor.create(name: "Dwolla", image: "processors/dwolla.png")
  end

  desc "Run all bootstrapping tasks"
  task :all => [:default_processors]
end