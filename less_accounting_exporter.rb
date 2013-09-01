require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'httparty'

class LessAccountingExporter
  include HTTParty

  def export_all(output_file = "output.json")
    all_data = {}
    all_data[:businesses] = get_businesses
    all_data[:bank_accounts] = get_bank_accounts
    all_data[:contacts] = get_contacts
    all_data[:currencies] = get_currencies
    all_data[:expense_categories] = get_expense_categories
    all_data[:expenses] = get_expenses
    all_data[:expenses_uncategorized] = get_expenses_uncategorized
    all_data[:invoices] = get_invoices
    all_data[:notes] = get_notes
    all_data[:payments] = get_payments
    all_data[:sales_taxes] = get_sales_taxes
    all_data[:tags] = get_tags

    File.write(output_file, all_data.to_json)
  end

  def initialize(config_file = nil)
    config_file ||= 'config.yml'

    if File.exist?(config_file)
      config = YAML.load(File.read(config_file))
    else
      raise "Cannot find #{config_file} file"
    end
    
    @auth    = { :username => config['username'], :password => config['password'] }
    @api_key = config['api_key']
    @domain  = "https://#{config['subdomain']}.lessaccounting.com"
    self.class.base_uri(@domain)
  end

  def get_businesses
    path = "/businesses/get_businesses.json"
    puts "running get_businesses (unpaged)"
    @get_businesses ||= get(path, false)
  end

  def get_bank_accounts
    path = "/bank_accounts.json"
    puts "running get_bank_accounts (unpaged)"
    @get_bank_accounts ||= get(path, false)
  end

  def get_contacts
    path = "/contacts.json"
    puts "running get_contacts (paged)"
    @get_contacts ||= get(path, true)
  end

  def get_currencies
    path = "/currencies.json"
    puts "running get_currencies (unpaged)"
    @get_currencies ||= get(path, false)
  end

  def get_expense_categories
    path = "/expense_categories.json"
    puts "running get_expense_categories (unpaged)"
    @get_expense_categories ||= get(path, false)
  end

  def get_expenses
    path = "/expenses.json"
    puts "running get_expenses (paged)"
    @get_expenses ||= get(path, true)
  end

  def get_expenses_uncategorized
    path = "/expenses/uncategorized.json"
    puts "running get_expenses_uncategorized (unpaged)"
    @get_expenses_uncategorized ||= get(path, false)
  end

  def get_invoices
    path = "/invoices.json"
    puts "running get_invoices (paged)"
    @get_invoices ||= get(path, true)
  end

  def get_notes
    path = "/notes.json"
    puts "running get_notes (paged)"
    @get_notes ||= get(path, true)
  end

  def get_payments
    path = "/payments.json"
    puts "running get_payments (paged)"
    @get_payments ||= get(path, true)
  end

  def get_sales_taxes
    path = "/sales_taxes.json"
    puts "running get_sales_taxes (unpaged)"
    @get_sales_taxes ||= get(path, false)
  end

  def get_tags
    path = "/tags.json"
    puts "run get_tags (unpaged)ning"
    @get_tags ||= get(path, false)
  end

private
  def options
    @_options ||= { :basic_auth => @auth, :query => {:api_key => @api_key} }
  end

  def get(path, paged = true)
    data = []
    page = 1
    loop do
      my_options = options
      my_options[:query].merge!({:page => page}) if paged
      puts "Fetching page ##{page}"
      resp = self.class.get(path, my_options)
      raise resp.inspect if resp.code != 200
      data += resp.parsed_response
      break if !paged || resp.parsed_response.count < 25
      page += 1
    end
    data    
  end

  def post(path)
    self.class.post(path, options)
  end
end