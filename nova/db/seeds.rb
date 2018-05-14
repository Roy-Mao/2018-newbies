# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create({
  nickname: 'geru',
  password: 'h0gehoge',
  email: 'geru@gmail.com',
  activated: true,
  activated_at: DateTime.now
})

User.create({
  nickname: 'hoge',
  password: 'h0gehoge',
  email: 'hoge@gmail.com',
  activated: true,
  activated_at: DateTime.now
})

20.times.each do |i|
  RemitRequest.create(user: User.first, target: User.second, amount: 100)
  RemitRequest.create(user: User.second, target: User.first, amount: 200)
end