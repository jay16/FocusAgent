desc "init db"
namespace :init do
  desc "create teas"
  task :tea => :environment do
    IO.readlines("./tea.txt").each do |line|
      array = line.split
      hash = {
        :name => array[0],
        :image => array[1],
        :from => array[2],
        :price => array[3],
        :unit1 => array[4],
        :unit2 => array[5],
        :weight => array[6],
        :unit3 => array[7],
        :desc => array[8]
      }
      tea = Tea.create(hash)
      puts "create:"+ tea.inspect
    end
  end
end
