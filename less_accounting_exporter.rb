require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'httparty'

class LessAccountingExporter
  include HTTParty

  def self.export_all(output_file = "output.json", config_file = nil)
    exporter = new(config_file)
    all_data = {}
    all_data[:businesses] = exporter.get_businesses
    all_data[:bank_accounts] = exporter.get_bank_accounts
    all_data[:contacts] = exporter.get_contacts
    all_data[:currencies] = exporter.get_currencies
    all_data[:expense_categories] = exporter.get_expense_categories
    all_data[:expenses] = exporter.get_expenses
    all_data[:expenses_uncategorized] = exporter.get_expenses_uncategorized
    all_data[:invoices] = exporter.get_invoices
    all_data[:notes] = exporter.get_notes
    all_data[:payments] = exporter.get_payments
    all_data[:sales_taxes] = exporter.get_sales_taxes
    all_data[:tags] = exporter.get_tags
    File.write(output_file) do |f|
      f << all_data.to_json
    end
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
    get(path, false)
  end

  def get_bank_accounts
    path = "/bank_accounts.json"
    get(path, false)
  end

  def get_contacts
    path = "/contacts.json"
    get(path, true)
  end

  def get_currencies
    path = "/currencies.json"
    get(path, false)
  end

  def get_expense_categories
    path = "/expense_categories.json"
    get(path, false)
  end

  def get_expenses
    path = "/expenses.json"
    get(path, true)
  end

  def get_expenses_uncategorized
    path = "/expenses/uncategorized.json"
    get(path, false)
  end

  def get_invoices
    path = "/invoices.json"
    get(path, true)
  end

  def get_notes
    path = "/notes.json"
    get(path, true)
  end

  def get_payments
    path = "/payments.json"
    get(path, true)
  end

  def get_sales_taxes
    path = "/sales_taxes.json"
    get(path, false)
  end

  def get_tags
    path = "/tags.json"
    get(path, false)
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