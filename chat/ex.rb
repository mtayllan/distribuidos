stop = false

Thread.new do
  10.times do |i|
    if i == 6
      stop = true
    end
    sleep 1
    puts 'sleepando'
  end
end

until stop
  puts 'nao paro'
  sleep 1
end

puts 'parei'
