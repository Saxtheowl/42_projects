# frozen_string_literal: true

puts 'Seeding database...'

# Create Admin
admin = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin'
)
puts 'Created admin user: admin@example.com / password123'

# Create Manager
manager = User.create!(
  email: 'manager@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jean',
  last_name: 'Manager',
  role: 'manager'
)
puts 'Created manager user: manager@example.com / password123'

# Create Operators
operators = []
User::OPERATOR_GROUPS.each_with_index do |group, index|
  operator = User.create!(
    email: "operator#{index + 1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    first_name: "Operator#{index + 1}",
    last_name: group,
    role: 'operator',
    operator_group: group
  )
  operators << operator
  puts "Created operator: operator#{index + 1}@example.com (#{group})"
end

# Create Companies
companies = []
company_names = ['Acme Corp', 'TechStart Inc', 'Global Solutions', 'Innovation Labs', 'Digital Dynamics']
company_names.each do |name|
  company = Company.create!(
    name: name,
    address: "123 #{name} Street, Paris",
    phone: "+33 1 23 45 67 89",
    email: "contact@#{name.downcase.gsub(' ', '')}.com"
  )
  companies << company
end
puts "Created #{companies.count} companies"

# Create Clients
clients = []
client_data = [
  { first_name: 'Pierre', last_name: 'Dupont', position: 'CEO' },
  { first_name: 'Marie', last_name: 'Martin', position: 'CTO' },
  { first_name: 'Jean', last_name: 'Bernard', position: 'Sales Director' },
  { first_name: 'Sophie', last_name: 'Leblanc', position: 'Marketing Manager' },
  { first_name: 'Philippe', last_name: 'Moreau', position: 'Project Manager' },
  { first_name: 'Claire', last_name: 'Rousseau', position: 'Finance Director' },
  { first_name: 'Michel', last_name: 'Durand', position: 'HR Manager' },
  { first_name: 'Anne', last_name: 'Petit', position: 'Operations Manager' }
]

client_data.each_with_index do |data, index|
  client = Client.create!(
    first_name: data[:first_name],
    last_name: data[:last_name],
    email: "#{data[:first_name].downcase}.#{data[:last_name].downcase}@example.com",
    phone: "+33 6 #{rand(10..99)} #{rand(10..99)} #{rand(10..99)} #{rand(10..99)}",
    position: data[:position],
    company: companies[index % companies.count],
    user: operators[index % operators.count]
  )
  clients << client
end
puts "Created #{clients.count} clients"

# Create Projects
projects = []
project_names = [
  'Website Redesign',
  'Mobile App Development',
  'CRM Implementation',
  'Marketing Campaign',
  'Infrastructure Upgrade'
]

project_names.each_with_index do |name, index|
  project = Project.create!(
    name: name,
    client: clients[index % clients.count],
    user: manager
  )
  projects << project

  # Create Quotes
  2.times do |q|
    quote = Quote.create!(
      project: project,
      intro: "<p>Thank you for considering our proposal for #{name}.</p><p>Below you will find our detailed quote.</p>",
      status: 'pending'
    )

    rand(2..4).times do
      LineItem.create!(
        itemable: quote,
        description: ['Consulting', 'Development', 'Design', 'Testing', 'Support'].sample,
        price: rand(500..5000),
        quantity: rand(1..10)
      )
    end
    quote.update_total!
  end

  # Create Order
  order = Order.create!(
    project: project,
    intro: "<p>Order confirmation for #{name}.</p>",
    status: 'confirmed'
  )

  rand(2..4).times do
    LineItem.create!(
      itemable: order,
      description: ['Service A', 'Service B', 'Product X', 'License'].sample,
      price: rand(500..3000),
      quantity: rand(1..5)
    )
  end
  order.update_total!

  # Create Invoices
  # Outgoing invoice (revenue)
  out_invoice = Invoice.create!(
    project: project,
    invoice_type: 'outgoing',
    intro: "<p>Invoice for services rendered.</p>",
    status: 'sent'
  )

  rand(2..3).times do
    LineItem.create!(
      itemable: out_invoice,
      description: ['Consulting Hours', 'Development Sprint', 'Monthly Support'].sample,
      price: rand(1000..5000),
      quantity: rand(1..3)
    )
  end
  out_invoice.update_total!

  # Incoming invoices (expenses)
  rand(1..3).times do
    in_invoice = Invoice.create!(
      project: project,
      invoice_type: 'incoming',
      intro: "<p>Expense invoice.</p>",
      status: 'paid'
    )

    rand(1..2).times do
      LineItem.create!(
        itemable: in_invoice,
        description: ['Equipment', 'Licenses', 'Subcontractor', 'Materials'].sample,
        price: rand(100..1000),
        quantity: rand(1..3)
      )
    end
    in_invoice.update_total!
  end
end
puts "Created #{projects.count} projects with quotes, orders, and invoices"

# Create Internal Messages
message_subjects = [
  'Team meeting tomorrow',
  'Project update required',
  'New client onboarded',
  'Weekly report',
  'Important announcement'
]

all_users = User.all.to_a
10.times do
  sender = all_users.sample
  recipient = (all_users - [sender]).sample

  InMail.create!(
    sender: sender,
    recipient: recipient,
    subject: message_subjects.sample,
    body: "Hello,\n\nThis is a sample message for demonstration purposes.\n\nBest regards,\n#{sender.full_name}",
    read: [true, false].sample
  )
end
puts 'Created 10 internal messages'

# Create Surveys
survey_topics = [
  { title: 'Customer Satisfaction Survey', questions: ['Are you satisfied with our service?', 'Would you recommend us?', 'Was the delivery on time?'] },
  { title: 'Product Feedback', questions: ['Is the product easy to use?', 'Does it meet your expectations?', 'Would you buy again?'] },
  { title: 'Employee Engagement', questions: ['Do you feel valued at work?', 'Is communication effective?', 'Are you satisfied with your role?'] }
]

survey_topics.each_with_index do |topic, index|
  survey = Survey.create!(
    title: topic[:title],
    intro: "<p>Thank you for taking the time to complete our survey.</p><p>Your feedback is important to us.</p>",
    thank_you: "<p>Thank you for your responses!</p><p>We appreciate your time and feedback.</p>",
    user: operators[index % operators.count],
    published: index < 2 # First two are published
  )

  topic[:questions].each do |question_text|
    SurveyQuestion.create!(
      survey: survey,
      question: question_text
    )
  end

  # Add some sample responses for published surveys
  if survey.published?
    rand(5..15).times do
      response = SurveyResponse.create!(
        survey: survey,
        email: "respondent#{rand(1..100)}@example.com"
      )

      survey.survey_questions.each do |question|
        SurveyAnswer.create!(
          survey_response: response,
          survey_question: question,
          answer: [true, false].sample
        )
      end
    end
  end
end
puts "Created #{Survey.count} surveys with responses"

# Create Activity Logs
ActivityLog.log(admin, 'seed_database', nil, 'Database seeded with demo data')
ActivityLog.log(manager, 'created_projects', nil, "Created #{projects.count} demo projects")
clients.take(3).each do |client|
  ActivityLog.log(operators.sample, 'created_client', client, client.full_name)
end
projects.take(3).each do |project|
  ActivityLog.log(manager, 'created_project', project, project.name)
end
puts 'Created activity logs'

puts ''
puts '=' * 50
puts 'SEED COMPLETED!'
puts '=' * 50
puts ''
puts 'Login credentials:'
puts '  Admin:    admin@example.com / password123'
puts '  Manager:  manager@example.com / password123'
puts '  Operator: operator1@example.com / password123'
puts ''
puts 'Start server with: rails server'
puts 'Then visit: http://localhost:3000'
puts '=' * 50
