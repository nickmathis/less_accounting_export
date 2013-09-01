LessAccounting Export Tool
======================

A basic export tool to handle most of the api calls for exporting data from LessAccounting (https://lessaccounting.com).

Requires setting up an API key in the application.

### Basic usage
```
# uses config.yml for authentication credentials
exporter = LessAccountingExporter.new

# Exports all the supported data and writes to a json file
exporter.export_all('output.json')

# Example of single export type, returns an array of hashes
exporter.get_bank_accounts
```
Exports the follow record types:
- businesses
- bank_accounts
- contacts
- currencies
- expense_categories
- expenses
- expenses_uncategorized
- invoices
- notes
- payments
- sales_taxes
- tags

For more details on api usage see https://welcome.lessaccounting.com/api
