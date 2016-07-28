require 'roo-xls'
require 'ostruct'
require 'yaml'
require 'csv'

class SEB2CSV
  class SEBKort 
    def initialize(files, out = STDOUT, options = SEB2CSV::DEFAULTS["sebkort"])
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
        sheet.find_all{|row| row[0].is_a?(Date)}.each do |row|
          r = OpenStruct.new
          r.date=row[0]
          r.bdate=row[1]
          r.vendor=row[2]
          r.city=row[3]
          r.currency=row[4]
          r.camount=row[5]
          r.amount=row[6]
          r.neg_amount=-r.amount
          r.crate="%0.2f" % (r.amount/r.camount) if not r.camount.to_f.zero?
          r.description="#{r.vendor}"
          r.description<<" #{r.city}" if r.city and not r.city.empty?
          r.description<<" (#{r.camount} #{r.currency}@#{r.crate})" if (r.currency and not r.currency.empty?)

          csv << rowitems.reduce([]) {|all, item| all << r[item]}
        end
      end
    end
  end
end
