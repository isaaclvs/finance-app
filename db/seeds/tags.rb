puts "Creating sample tags..."

user = User.find_by(email: SEED_USER_EMAIL)
return unless user

tags_data = [
  { name: "Essential",     color: "#10B981" },
  { name: "Leisure",       color: "#EC4899" },
  { name: "Work",          color: "#3B82F6" },
  { name: "Health",        color: "#F59E0B" },
  { name: "Family",        color: "#8B5CF6" },
  { name: "Subscription",  color: "#6366F1" },
  { name: "One-time",      color: "#EF4444" },
  { name: "Recurring",     color: "#14B8A6" }
]

tags_data.each do |attrs|
  tag = user.tags.find_or_create_by!(name: attrs[:name]) do |t|
    t.color = attrs[:color]
  end
  puts "  Tag: #{tag.name}"
end

puts "Total tags: #{user.tags.count}"
