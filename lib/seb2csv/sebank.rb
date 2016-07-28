require 'roo'
require 'ostruct'
require 'yaml'
require 'csv'

class SEB2CSV
  class SEBank
    def initialize(files, out = STDOUT, options = SEB2CSV::DEFAULTS["sebank"])
      header = options.reduce([]) do |all, item|
        key, value = item.flatten
        all << key
      end

      rowitems = options.reduce([]) do |all, item|
        key, value = item.flatten
        all << value
      end

      csv = CSV.new(out)
      csv << header

      files.each do |file|
        sheet=Roo::Spreadsheet.open(file)
        sheet.find_all{|row| /[0-9]{4}-[0-9]{2}-[0-9]{2}/ =~ row[0]}.each do |row|
          r = OpenStruct.new
          r.date=row[0]
          r.cdate=row[1]
          r.verification=row[2]
          r.description=row[3]
          r.amount=row[4]
          r.neg_amount=-r.amount

          csv << rowitems.reduce([]) {|all, item| all << r[item]}
        end
      end
    end
  end
end